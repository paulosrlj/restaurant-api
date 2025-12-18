# Restaurant API

This is a RESTful API built with **Ruby on Rails** for managing restaurants, menus, and menu items.
It also provides a **JSON-to-model importer** that allows bulk creation of records from a structured JSON payload.

---

## 🐳 Running the Application with Docker

This project is fully dockerized.

### 1️⃣ Build the containers

```bash
docker compose build
```

### 2️⃣ Start the applicationa

```bash
docker compose up
```

The API will be available at:

```
http://localhost:3000
```

---

## 🧪 Tests

The project includes request specs and service specs using **RSpec**.

To run tests inside the container:

```bash
docker compose run -e RAILS_ENV=test api bundle exec rspec
```

---


## 📡 API Endpoints

### Restaurants

| Method      | Endpoint                  | Description          |
| ----------- | ------------------------- | -------------------- |
| GET         | `/api/v1/restaurants`     | List all restaurants |
| POST        | `/api/v1/restaurants`     | Create a restaurant  |
| GET         | `/api/v1/restaurants/:id` | Show a restaurant    |
| PATCH / PUT | `/api/v1/restaurants/:id` | Update a restaurant  |
| DELETE      | `/api/v1/restaurants/:id` | Delete a restaurant  |

---

### Menus

| Method      | Endpoint            | Description    |
| ----------- | ------------------- | -------------- |
| GET         | `/api/v1/menus`     | List all menus |
| POST        | `/api/v1/menus`     | Create a menu  |
| GET         | `/api/v1/menus/:id` | Show a menu    |
| PATCH / PUT | `/api/v1/menus/:id` | Update a menu  |
| DELETE      | `/api/v1/menus/:id` | Delete a menu  |

---

### Menu Items

| Method      | Endpoint                 | Description         |
| ----------- | ------------------------ | ------------------- |
| GET         | `/api/v1/menu_items`     | List all menu items |
| POST        | `/api/v1/menu_items`     | Create a menu item  |
| GET         | `/api/v1/menu_items/:id` | Show a menu item    |
| PATCH / PUT | `/api/v1/menu_items/:id` | Update a menu item  |
| DELETE      | `/api/v1/menu_items/:id` | Delete a menu item  |

---

### JSON Importer

| Method | Endpoint                        | Description                      |
| ------ | ------------------------------- | -------------------------------- |
| POST   | `/api/v1/json_to_model/convert` | - Import nested JSON into database, and returns a list of success/errors of insert operations; |

---

## 📥 Supported Input Formats

The JSON Importer accepts data in two different ways:

✅ 1. JSON in the Request Body

Send the payload directly in the request body with the header:

Content-Type: application/json

Example:

POST /api/v1/json_to_model/convert

```json
{
  "restaurants": [
    {
      "name": "Poppo's Cafe",
      "menus": [
        {
          "name": "lunch",
          "menu_items": [
            { "name": "Burger", "price": 9.00 },
            { "name": "Small Salad", "price": 5.00 }
          ]
        }
      ]
    }
  ]
}
```

✅ 2. Multipart Form Data (JSON File Upload)

You can also upload a JSON file using multipart/form-data.

The file must:

Be sent under the file attribute

Have Content-Type: application/json

Example using curl:

```
curl -X POST http://localhost:3000/api/v1/json_to_model/convert \
  -F "file=@payload.json;type=application/json"
```


The contents of payload.json must follow the same structure as the JSON body example.


## 📊 Importer Response

The importer does not abort the entire operation if one record fails.

It returns a report with detailed information about each insert attempt.

### Example response:

```json
{
  "data": {
    "total": 6,
    "success": 5,
    "errors": 1,
    "details": [
      {
        "entity": "MenuItem",
        "attributes": { "name": "Burger", "price": 9.0 },
        "status": "success",
        "id": 12
      },
      {
        "entity": "MenuItem",
        "attributes": { "name": "Burger", "price": 9.0 },
        "status": "error",
        "errors": ["Name has already been taken"]
      }
    ]
  }
}
```

---

### Example JSON Payload

```json
{
  "restaurants": [
    {
      "name": "Poppo's Cafe",
      "menus": [
        {
          "name": "lunch",
          "menu_items": [
            {
              "name": "Burger",
              "price": 9.00
            },
            {
              "name": "Small Salad",
              "price": 5.00
            }
          ]
        },
        {
          "name": "dinner",
          "menu_items": [
            {
              "name": "Burger",
              "price": 15.00
            },
            {
              "name": "Large Salad",
              "price": 8.00
            }
          ]
        }
      ]
    },
    {
      "name": "Casa del Poppo",
      "menus": [
        {
          "name": "lunch",
          "dishes": [
            {
              "name": "Chicken Wings",
              "price": 9.00
            },
            {
              "name": "Burger",
              "price": 9.00
            },
            {
              "name": "Chicken Wings",
              "price": 9.00
            }
          ]
        },
        {
          "name": "dinner",
          "dishes": [
            {
              "name": "Mega \"Burger\"",
              "price": 22.00
            },
            {
              "name": "Lobster Mac & Cheese",
              "price": 31.00
            }
          ]
        }
      ]
    }
  ]
}
```

## 📬 API Format

### Success Response

```json
{
  "data": { ... }
}
```

### Error Response

```json
{
  "errors": ["Error message"]
}
```

---

## 📌 License

This project is for educational and demonstration purposes.