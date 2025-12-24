// Minimal mdns-sd test to verify basic functionality
use mdns_sd::{ServiceDaemon, ServiceInfo};
use std::collections::HashMap;
use std::thread;
use std::time::Duration;

fn main() {
    println!("🧪 Starting minimal mdns-sd test...");

    // Create ServiceDaemon
    let daemon = match ServiceDaemon::new() {
        Ok(d) => {
            println!("✅ ServiceDaemon created successfully");
            d
        }
        Err(e) => {
            eprintln!("❌ Failed to create ServiceDaemon: {}", e);
            return;
        }
    };

    // Get local IP
    let local_ip = if_addrs::get_if_addrs()
        .ok()
        .and_then(|addrs| {
            addrs
                .into_iter()
                .find(|addr| !addr.is_loopback() && addr.ip().is_ipv4())
                .map(|addr| addr.ip())
        })
        .unwrap_or_else(|| "127.0.0.1".parse().unwrap());

    println!("🌐 Using local IP: {}", local_ip);

    // Register a test service
    let service_type = "_mdnstest._tcp.local.";
    let instance_name = "test-instance";
    let hostname = "test.local.";
    let port = 12345;

    println!("📝 Creating ServiceInfo:");
    println!("   Type: {}", service_type);
    println!("   Instance: {}", instance_name);
    println!("   Host: {}", hostname);
    println!("   IP: {}", local_ip);
    println!("   Port: {}", port);

    let mut properties = HashMap::new();
    properties.insert("test".to_string(), "value".to_string());

    let service_info = ServiceInfo::new(
        service_type,
        instance_name,
        hostname,
        local_ip,
        port,
        Some(properties),
    )
    .expect("Failed to create ServiceInfo");

    println!("📡 Registering service...");
    match daemon.register(service_info) {
        Ok(_) => println!("✅ Service registered successfully"),
        Err(e) => {
            eprintln!("❌ Failed to register service: {}", e);
            return;
        }
    }

    // Browse for services
    println!(
        "🔍 Starting to browse for services of type: {}",
        service_type
    );
    let browse_receiver = match daemon.browse(service_type) {
        Ok(receiver) => {
            println!("✅ Browse started successfully");
            receiver
        }
        Err(e) => {
            eprintln!("❌ Failed to start browsing: {}", e);
            return;
        }
    };

    // Spawn thread to handle events
    let browse_thread = thread::spawn(move || {
        println!("🧵 Browse thread started");
        let mut event_count = 0;
        loop {
            match browse_receiver.recv_timeout(Duration::from_secs(1)) {
                Ok(event) => {
                    event_count += 1;
                    println!("📬 [Event #{}] Received: {:?}", event_count, event);
                }
                Err(e) if e.to_string().contains("timeout") => {
                    // This is normal, just means no events in the last second
                    continue;
                }
                Err(e) => {
                    eprintln!("❌ Error receiving event: {}", e);
                    break;
                }
            }
        }
    });

    println!("\n⏳ Waiting 10 seconds for mDNS activity...");
    println!("   (In another terminal, run: avahi-browse -a -t -r | grep mdnstest)\n");

    thread::sleep(Duration::from_secs(10));

    println!("\n🛑 Stopping test...");
    drop(daemon);

    println!("✅ Test complete");
}
