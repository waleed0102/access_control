# Access Control System

A comprehensive Rails-based access control system designed for organizations to manage user participation with age-based rules, parental consent workflows, and role-based permissions.

## 🚀 Features

### Core Functionality
- **User Authentication & Registration** - Secure user management with Devise
- **Organization Management** - Multi-tenant organization support
- **Role-Based Access Control** - Flexible role system with CanCanCan and Rolify
- **Age-Based Participation Rules** - Automatic age group assignment and restrictions
- **Parental Consent Workflows** - Required consent for minors with approval tracking
- **Participation Spaces** - Controlled environments with specific access rules
- **Analytics Dashboard** - Comprehensive reporting and insights

### Access Control Features
- **Content Filtering** - Age-appropriate content levels
- **Time Restrictions** - Configurable access hours
- **Activity Permissions** - Granular control over allowed/restricted activities
- **Real-time Validation** - Instant access verification
- **Audit Trail** - Complete activity logging

## 🛠 Technology Stack

- **Ruby on Rails** 6.1+ - Web framework
- **Ruby** 3.0+ - Programming language
- **SQLite** - Database (development)
- **Bootstrap 5** - Frontend framework
- **Font Awesome** - Icons
- **Devise** - Authentication
- **CanCanCan** - Authorization
- **Rolify** - Role management

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- Ruby 3.0 or higher
- Rails 6.1 or higher
- SQLite3
- Node.js and Yarn (for asset compilation)

## ⚡ Quick Setup

### 1. Clone the Repository
```bash
git clone https://github.com/waleed0102/access_control.git
cd access_control
```

### 2. Install Dependencies
```bash
bundle install
yarn install
```

### 3. Database Setup
```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4. Start the Server
```bash
rails server
```

Visit `http://localhost:3000` to access the application.

## 🔧 Detailed Setup

### Environment Configuration

1. **Database Configuration**
   - Edit `config/database.yml` if you need to change database settings
   - Default uses SQLite for development

2. **Environment Variables**
   - Copy `.env.example` to `.env` (if applicable)
   - Configure any required environment variables

3. **Asset Compilation**
   ```bash
   rails assets:precompile
   ```

### Initial Data

The seed file creates:
- **Age Groups**: Toddler, Child, Teen, Young Adult, Adult
- **Sample Organizations**: Educational, Community, Sports
- **Participation Spaces**: Age-appropriate spaces for each organization
- **Test Users**: Users across different age groups with various roles
- **Parental Consents**: Sample consent records for minors

## 👥 User Roles & Permissions

### Role Hierarchy
1. **Member** - Basic access to organization spaces
2. **Moderator** - Can manage participation spaces and moderate content
3. **Admin** - Full organization management capabilities

### Age-Based Access
- **Toddler (0-3)**: Restricted access, requires parental consent
- **Child (4-12)**: Limited activities, content filtering
- **Teen (13-17)**: Moderate restrictions, some independence
- **Young Adult (18-25)**: Most activities allowed
- **Adult (26+)**: Full access to all features

## 🏢 Organization Management

### Creating Organizations
1. Navigate to Organizations page
2. Click "Create New Organization"
3. Fill in organization details
4. Assign admin users

### Managing Participation Spaces
1. Access organization dashboard
2. Navigate to Participation Spaces
3. Create spaces with specific:
   - Age group restrictions
   - Content filter levels
   - Time restrictions
   - Activity permissions

## 🔐 Access Control Workflows

### User Registration
1. User signs up with personal information
2. System automatically assigns age group
3. If minor, parental consent required
4. User joins organization (optional)

### Parental Consent Process
1. Minor user attempts to access restricted content
2. System redirects to parental consent form
3. Parent provides consent with verification
4. Access granted upon approval

### Space Access Verification
1. User attempts to access participation space
2. System checks:
   - Age group compatibility
   - Role permissions
   - Time restrictions
   - Parental consent (if required)
3. Access granted or denied with explanation

## 📊 Analytics & Reporting

### Available Reports
- **User Demographics** - Age group distribution
- **Access Patterns** - Popular spaces and times
- **Consent Tracking** - Parental consent statistics
- **Role Distribution** - User role analytics
- **Space Utilization** - Participation space usage

### Accessing Analytics
1. Navigate to organization dashboard
2. Click "Analytics" (admin/moderator only)
3. View comprehensive reports and charts

## 🎨 Customization

### Styling
- Modify `app/assets/stylesheets/application.css`
- Update Bootstrap theme variables
- Customize component styles

### Access Rules
- Edit `app/models/participation_space.rb` for rule logic
- Modify age group configurations in seeds
- Update role permissions in controllers

### Workflows
- Customize parental consent process
- Modify access validation logic
- Add new role types

### Environment Variables
```bash
RAILS_ENV=production
DATABASE_URL=your_database_url
SECRET_KEY_BASE=your_secret_key
```

## 🔒 Security Considerations

### Authentication
- Devise provides secure authentication
- Password requirements enforced
- Session management included

### Authorization
- Role-based access control
- Age-appropriate content filtering
- Parental consent verification

### Data Protection
- User data encryption
- Audit trail for sensitive operations
- GDPR compliance considerations

## 📝 API Documentation

### Available Endpoints
- `GET /api/organizations` - List organizations
- `GET /api/participation_spaces` - List spaces
- `POST /api/parental_consents` - Submit consent
- `GET /api/analytics` - Access analytics data

### Authentication
- API tokens required for external access
- Rate limiting implemented
- CORS configuration available
