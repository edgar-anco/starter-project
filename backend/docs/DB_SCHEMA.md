# Database Schema - News App

## Collections

### `articles`

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `id` | string | Unique identifier (UUID) | Yes |
| `author` | string | Author name | Yes |
| `title` | string | Article title (max 100 chars) | Yes |
| `description` | string | Brief description (max 200 chars) | No |
| `content` | string | Full article content (max 5000 chars) | Yes |
| `thumbnailUrl` | string | Reference to Cloud Storage path | No |
| `publishedAt` | timestamp | Publication date | Yes |
| `createdAt` | timestamp | Document creation date | Yes |
| `updatedAt` | timestamp | Last update date | Yes |

### Storage Structure

```
media/
  └── articles/
      └── {articleId}/
          └── thumbnail.{extension}
```

### Example Document

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "author": "John Doe",
  "title": "Breaking News: Flutter is Awesome",
  "description": "A brief overview of why Flutter continues to dominate",
  "content": "Full article content here...",
  "thumbnailUrl": "https://storage.googleapis.com/...",
  "publishedAt": "2026-01-17T12:00:00Z",
  "createdAt": "2026-01-17T11:55:00Z",
  "updatedAt": "2026-01-17T11:55:00Z"
}
```