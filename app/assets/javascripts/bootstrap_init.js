// Bootstrap initialization for Turbolinks
document.addEventListener('turbolinks:load', function() {
  // Wait a bit for Bootstrap to be ready
  setTimeout(function() {
    // Initialize dropdowns
    var dropdowns = document.querySelectorAll('[data-bs-toggle="dropdown"]');
    dropdowns.forEach(function(dropdown) {
      // Remove any existing dropdown instances
      var existingInstance = bootstrap.Dropdown.getInstance(dropdown);
      if (existingInstance) {
        existingInstance.dispose();
      }
      // Create new dropdown instance
      new bootstrap.Dropdown(dropdown);
    });

    // Initialize alerts
    var alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert) {
      new bootstrap.Alert(alert);
    });

    // Initialize tooltips
    var tooltips = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    tooltips.forEach(function(tooltip) {
      var existingInstance = bootstrap.Tooltip.getInstance(tooltip);
      if (existingInstance) {
        existingInstance.dispose();
      }
      new bootstrap.Tooltip(tooltip);
    });
  }, 50);
});

// Also initialize on regular page load
document.addEventListener('DOMContentLoaded', function() {
  setTimeout(function() {
    var dropdowns = document.querySelectorAll('[data-bs-toggle="dropdown"]');
    dropdowns.forEach(function(dropdown) {
      new bootstrap.Dropdown(dropdown);
    });
  }, 50);
}); 