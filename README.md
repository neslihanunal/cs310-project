# CS310 – MOBILE APPLICATION DEVELOPMENT

## Project Title & Description
**CampusBoard** is a mobile application designed to centralize university club events into a single platform. The app provides students with an interactive dashboard to discover upcoming campus events, while allowing authorized university club representatives to create and manage event announcements.

Instead of searching through social media posts, posters, and emails, students can discover events through a visual digital bulletin board.

## Problem
Campus communication is often fragmented. Students frequently miss important club events because announcements are scattered across different platforms such as social media, physical posters, email newsletters, and messaging groups. This makes it difficult for students to stay informed about campus life.

## Solution
CampusBoard provides a centralized event dashboard where university club events are displayed in one place.

The application separates users into two roles:

**Students**
- Discover upcoming events
- View event details
- Save events
- Receive reminders for saved events

**Club Admins**
- Create and manage event announcements
- Edit or delete outdated event posts
- Reach students directly through the platform

## Core Features

### Role-Based Authentication
Users log in and are directed to different interfaces depending on their role:
- Student Dashboard
- Club Admin Portal

### Interactive Post-It Dashboard
Upcoming events are displayed as digital post-it notes on a virtual bulletin board.

Each post-it contains:
- Event title
- Date and time
- Location
- Hosting club

Students can tap a post-it to view full event details.

### Event Creation and Management System
Club admins can:
- Create events
- Edit event information
- Delete outdated or incorrect announcements
- Manage event content through the admin portal

### Event Save and Reminder System
Students can save events they are interested in and receive notifications before the event begins.

## Optional Features

### Event Category Filtering
Events can be categorized and filtered by type:
- Academic
- Social
- Sports
- Career
- Networking

### Poster Upload Support
Club admins can upload event posters (JPEG / PNG). Students can tap a post-it to view the full poster.

### RSVP / Attendance Indication
Students can indicate whether they plan to attend an event. This feature can help clubs estimate participation more effectively.

### Calendar Integration
Students can add saved events directly to their personal calendars (e.g., Google Calendar). Event details such as title, location, and time will automatically appear in their calendar to help them keep track of campus activities.

### Map Integration
Events can be displayed on an interactive campus map. Students can easily view where events are taking place and navigate to the venue.

### Multi-University Support
The platform can scale beyond a single university by allowing users to filter events by institution.

Example:
- Sabancı University
- Koç University
- Bilkent University

### Post-Event Review and Comment System
Students can leave ratings and comments after attending an event. This feature can provide useful feedback to clubs and improve community interaction.

## Technical Stack & Architecture

**Frontend (Client-Side)**
- **Framework:** Flutter
- **Language:** Dart

**Backend (Serverless Infrastructure)**
- **Database:** Cloud Firestore
- **Authentication:** Firebase Authentication
- **Media Storage:** Firebase Cloud Storage

**Version Control & Collaboration**
- **Repository:** GitHub

## Data Structure
- **User Data:** Authentication credentials, profile details, and role-based access permissions
- **Entity Data:** Verified club profiles and related organizational information
- **Event Data:** Event titles, timestamps, descriptions, locations, and the authoring club ID
- **Core Interaction Data:** Saved events and reminder-related records
- **Optional Engagement Data:** RSVP records and user reviews/comments if these features are implemented later
- **File Storage:** Cloud storage for uploaded JPEG / PNG poster assets

## Unique Selling Point
Unlike generic list-based calendar apps or cluttered social media platforms, CampusBoard provides a dedicated creation interface for clubs and a focused discovery feed for students. The visual post-it note interface reduces digital noise and makes event discovery more intuitive and engaging for university users.

## Potential Challenges
- UI performance when many events are displayed
- Secure role-based access control
- Real-time synchronization of event updates
- Image optimization for poster uploads

## Team Members
- Emir Mirza – Presentation & Communication Lead
- Erkan Ulaş Tepe – Learning & Research Lead
- Mirhat Harıkcı – Testing & Quality Assurance Lead
- Murat Çankaya – Project Coordinator
- Neslihan Ünal – Documentation & Submission Lead
- Sıla Kara – Integration & Repository Lead
