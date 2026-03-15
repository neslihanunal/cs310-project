# CS310 – MOBILE APPLICATION DEVELOPMENT

## Project Title & Description
**CampusBoard** is a mobile application designed to centralize university club events into a single platform. The app provides students with an interactive dashboard to discover upcoming campus events, while allowing university club PR teams to create and manage event announcements.

Instead of searching through social media posts, posters, and emails, students can discover events through a visual digital bulletin board.

## Problem
Campus communication is often fragmented. Students frequently miss important club events because announcements are scattered across different platforms such as; social media, physical posters, email newsletters, messaging groups. This makes it difficult for students to stay informed about campus life.

## Solution
CampusBoard provides a centralized event dashboard where all university club events are displayed in one place.

The application separates users into two roles:

**Students**
- Discover upcoming events
- Save events
- Receive reminders
- Leave reviews after attending events

**Club PR Teams**
- Create and manage event announcements
- Upload event posters
- Reach students directly through the platform
- Get feedback through reviews

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

### Event Creation System
Club PR teams can:
- Create events
- Edit event information
- Cancel events (it will be still seen as canceled)
- Upload posters

### Event Reminder System
Students can save events and receive notifications before the event begins.

### Review and Comment System
After events take place, students can:
- Leave ratings
- Write comments
- Provide feedback to clubs

## Optional Features

### Multi-University Support
The platform can scale beyond a single university by allowing users to filter events by institution.

Example:
- Sabancı University
- Koç University
- Bilkent University

### Event Category Filtering
Events can be categorized and filtered by type:
- Academic
- Social
- Sports
- Career
- Networking

### Poster Upload Support
Club admins can upload event posters (JPEG / PNG). Students can tap a post-it to view the full poster.

### Calendar Integration
Students can add saved events directly to their personal calendars (e.g., Google Calendar). Event details such as title, location, and time will automatically appear in their calendar to help them keep track of campus activities.

### Map Integration
Events can be displayed on an interactive campus map. Students can easily view where events are taking place and tap the location to navigate to the venue.

## Technical Stack & Architecture

**Frontend (Client-Side)**
- **Framework:** Flutter (Cross-platform UI toolkit for rendering native-compiled applications for iOS and Android from a single codebase).
- **Language:** Dart
- **State Management:**

**Backend (Serverless Infrastructure)**
- **Database:** Cloud Firestore (NoSQL document database ensuring real-time data synchronization across user devices for event updates and RSVP tracking).
- **Authentication:** Firebase Authentication (Secure, token-based authentication handling the Role-Based Access Control between Student and Admin accounts).
- **Media Storage:** Firebase Cloud Storage (Optimized cloud bucket for hosting, compressing, and serving user-uploaded JPEG/PNG event posters).

**Version Control & Collaboration**
- **Repository:** GitHub (Utilized for source code hosting, branch management, and collaborative integration).

## Data Structure
- **User Data:** Authentication credentials, profile details, and role-based access permissions (Admin vs. Student).
- **Entity Data:** Verified club profiles linked to specific universities.
- **Event Data:** Content for the post-its, including titles, timestamps, descriptions, locations, and the authoring club ID.
- **Engagement Data:** User RSVP lists, stored reminders, and associated user reviews/comments.
- **File Storage:** Utilizing a cloud storage bucket (like Firebase Storage) to securely handle, compress, and serve uploaded JPEG/PNG poster assets.


## Unique Selling Point
Unlike generic list-based calendar apps or cluttered social media platforms, CampusBoard provides a dedicated set of creation tools for clubs and a dedicated discovery feed for students. The unique, visual "post-it note" UI cuts out unrelated digital noise, making event discovery intuitive and aesthetically engaging for the university demographic.

## Potential Challenges
- UI performance when many events are displayed
- Secure role-based access control
- Real-time synchronization of event updates
- Image optimization for poster uploads

## Team Members
- Emir Mirza – Presentation & Communication Lead
- Erkan Ulaş Tepe – Integration & Repository Lead
- Mirhat Harıkcı – Testing & Quality Assurance Lead
- Murat Çankaya – Project Coordinator
- Neslihan Ünal – Documentation & Submission Lead
- Sıla Kara – Integration & Repository Lead

