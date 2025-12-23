# BlueNote API Specification

_Last updated: 2025-12-23_

---

## 1. API Overview

BlueNote provides a secure, real-time communication platform for medical offices. The API is designed with:

- **RESTful principles** for resource management (CRUD)
- **WebSocket API** for real-time events (lights, messages, alerts)
- **Token-based authentication** (JWT)
- **Role-based authorization**
- **Rate limiting** to prevent abuse

---

## 2. REST API Endpoints

### 2.1. Lights

#### List Lights

- **GET** `/api/v1/lights`
- **Response:**
  ```json
  [
    {
      "id": "light-123",
      "name": "Exam Room 1",
      "status": "active",
      "tags": ["urgent", "doctor"],
      "lastActivatedAt": "2025-12-23T10:15:00Z"
    }
  ]
  ```
- **Status Codes:** 200, 401

#### Create Light

- **POST** `/api/v1/lights`
- **Request:**
  ```json
  {
    "name": "Exam Room 2",
    "tags": ["nurse"]
  }
  ```
- **Response:**
  ```json
  {
    "id": "light-124",
    "name": "Exam Room 2",
    "status": "inactive",
    "tags": ["nurse"]
  }
  ```
- **Status Codes:** 201, 400, 401
