class Events {
    constructor(container) {
        this.container = container;
        this.events = [];
        this.init();
    }

    async init() {
        this.showLoading();
        try {
            await this.fetchEvents();
            this.render();
        } catch (error) {
            console.error('Events initialization error:', error);
            this.showError();
        }
    }

    async fetchEvents() {
        const response = await fetch('/api/events', {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
        });
        this.events = await response.json();
    }

    showLoading() {
        this.container.innerHTML = `
            <div class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
            </div>
        `;
    }

    showError() {
        this.container.innerHTML = `
            <div class="alert alert-danger" role="alert">
                Error loading events. Please try again later.
            </div>
        `;
    }

    render() {
        this.container.innerHTML = `
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Events</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" class="btn btn-primary" onclick="events.showAddModal()">
                        <i class="bi bi-plus"></i> Add Event
                    </button>
                </div>
            </div>

            <!-- Filters -->
            <div class="row mb-3">
                <div class="col-md-3">
                    <input type="text" class="form-control" id="searchEvent" placeholder="Search events...">
                </div>
                <div class="col-md-3">
                    <select class="form-select" id="filterCategory">
                        <option value="">All Categories</option>
                        ${this.getUniqueCategories().map(category => 
                            `<option value="${category}">${category}</option>`
                        ).join('')}
                    </select>
                </div>
                <div class="col-md-3">
                    <select class="form-select" id="filterStatus">
                        <option value="">All Status</option>
                        <option value="upcoming">Upcoming</option>
                        <option value="ongoing">Ongoing</option>
                        <option value="past">Past</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <input type="month" class="form-control" id="filterMonth">
                </div>
            </div>

            <!-- Events Calendar View -->
            <div class="card mb-4">
                <div class="card-body" id="calendarView">
                    <!-- Calendar will be rendered here -->
                </div>
            </div>

            <!-- Events List View -->
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Date & Time</th>
                            <th>Location</th>
                            <th>Category</th>
                            <th>Registration</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${this.renderEventRows()}
                    </tbody>
                </table>
            </div>

            ${this.renderModals()}
        `;

        this.initializeCalendar();
        this.initEventListeners();
    }

    renderEventRows() {
        return this.events.map(event => `
            <tr>
                <td>${event.title}</td>
                <td>
                    ${this.formatDate(event.startDate)}<br>
                    <small class="text-muted">${this.formatTime(event.startDate)} - ${this.formatTime(event.endDate)}</small>
                </td>
                <td>${event.location}</td>
                <td><span class="badge bg-secondary">${event.category}</span></td>
                <td>
                    ${event.requiresRegistration ? 
                        `<span class="badge bg-${event.isFull ? 'danger' : 'success'}">
                            ${event.currentAttendees}/${event.maxAttendees}
                        </span>` : 
                        '<span class="badge bg-info">Not Required</span>'
                    }
                </td>
                <td>${this.getEventStatus(event)}</td>
                <td>
                    <div class="btn-group">
                        <button class="btn btn-sm btn-outline-primary" onclick="events.showEditModal(${event.id})">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger" onclick="events.confirmDelete(${event.id})">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');
    }

    renderModals() {
        return `
            <!-- Add/Edit Event Modal -->
            <div class="modal fade" id="eventModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="eventModalTitle">Add Event</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <form id="eventForm">
                                <input type="hidden" id="eventId">
                                <div class="row mb-3">
                                    <div class="col-md-8">
                                        <label for="title" class="form-label">Title</label>
                                        <input type="text" class="form-control" id="title" required>
                                    </div>
                                    <div class="col-md-4">
                                        <label for="category" class="form-label">Category</label>
                                        <input type="text" class="form-control" id="category" required>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label for="description" class="form-label">Description</label>
                                    <textarea class="form-control" id="description" rows="3"></textarea>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="startDate" class="form-label">Start Date & Time</label>
                                        <input type="datetime-local" class="form-control" id="startDate" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="endDate" class="form-label">End Date & Time</label>
                                        <input type="datetime-local" class="form-control" id="endDate" required>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label for="location" class="form-label">Location</label>
                                    <input type="text" class="form-control" id="location" required>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="isRecurring">
                                            <label class="form-check-label" for="isRecurring">
                                                Recurring Event
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-md-6" id="recurrenceOptions" style="display: none;">
                                        <select class="form-select" id="recurrenceRule">
                                            <option value="FREQ=WEEKLY">Weekly</option>
                                            <option value="FREQ=MONTHLY">Monthly</option>
                                            <option value="FREQ=YEARLY">Yearly</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="requiresRegistration">
                                            <label class="form-check-label" for="requiresRegistration">
                                                Requires Registration
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-md-6" id="registrationOptions" style="display: none;">
                                        <label for="maxAttendees" class="form-label">Maximum Attendees</label>
                                        <input type="number" class="form-control" id="maxAttendees" min="1">
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label for="imageFile" class="form-label">Event Image</label>
                                    <input type="file" class="form-control" id="imageFile" accept="image/*">
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" class="btn btn-primary" onclick="events.saveEvent()">Save</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Delete Confirmation Modal -->
            <div class="modal fade" id="deleteModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Delete Event</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            Are you sure you want to delete this event?
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" class="btn btn-danger" onclick="events.deleteEvent()">Delete</button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }

    getUniqueCategories() {
        return [...new Set(this.events.map(event => event.category))];
    }

    formatDate(dateString) {
        return new Date(dateString).toLocaleDateString('en-US', {
            weekday: 'short',
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    }

    formatTime(dateString) {
        return new Date(dateString).toLocaleTimeString('en-US', {
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    getEventStatus(event) {
        const now = new Date();
        const startDate = new Date(event.startDate);
        const endDate = new Date(event.endDate);

        if (now < startDate) {
            return '<span class="badge bg-primary">Upcoming</span>';
        } else if (now > endDate) {
            return '<span class="badge bg-secondary">Past</span>';
        } else {
            return '<span class="badge bg-success">Ongoing</span>';
        }
    }

    initializeCalendar() {
        const calendarEl = document.getElementById('calendarView');
        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay'
            },
            events: this.events.map(event => ({
                id: event.id,
                title: event.title,
                start: event.startDate,
                end: event.endDate,
                allDay: false,
                backgroundColor: this.getCategoryColor(event.category),
                extendedProps: {
                    location: event.location,
                    description: event.description
                }
            })),
            eventClick: (info) => {
                this.showEventDetails(this.events.find(e => e.id === parseInt(info.event.id)));
            },
            eventDidMount: (info) => {
                tippy(info.el, {
                    content: `
                        <strong>${info.event.title}</strong><br>
                        ${this.formatTime(info.event.start)} - ${this.formatTime(info.event.end)}<br>
                        ${info.event.extendedProps.location}
                    `,
                    allowHTML: true
                });
            }
        });
        calendar.render();
    }

    getCategoryColor(category) {
        // Map categories to colors or generate consistent colors
        const colors = {
            'Worship Service': '#4CAF50',
            'Bible Study': '#2196F3',
            'Youth Event': '#FF9800',
            'Special Event': '#9C27B0'
        };
        return colors[category] || '#607D8B';
    }

    initEventListeners() {
        // Search functionality
        document.getElementById('searchEvent').addEventListener('input', (e) => {
            this.filterEvents();
        });

        // Category filter
        document.getElementById('filterCategory').addEventListener('change', () => {
            this.filterEvents();
        });

        // Status filter
        document.getElementById('filterStatus').addEventListener('change', () => {
            this.filterEvents();
        });

        // Month filter
        document.getElementById('filterMonth').addEventListener('change', () => {
            this.filterEvents();
        });

        // Recurring event checkbox
        document.getElementById('isRecurring').addEventListener('change', (e) => {
            document.getElementById('recurrenceOptions').style.display = 
                e.target.checked ? 'block' : 'none';
        });

        // Registration checkbox
        document.getElementById('requiresRegistration').addEventListener('change', (e) => {
            document.getElementById('registrationOptions').style.display = 
                e.target.checked ? 'block' : 'none';
        });
    }

    filterEvents() {
        const searchTerm = document.getElementById('searchEvent').value.toLowerCase();
        const category = document.getElementById('filterCategory').value;
        const status = document.getElementById('filterStatus').value;
        const month = document.getElementById('filterMonth').value;

        const filteredEvents = this.events.filter(event => {
            const matchesSearch = event.title.toLowerCase().includes(searchTerm) ||
                                event.description.toLowerCase().includes(searchTerm) ||
                                event.location.toLowerCase().includes(searchTerm);

            const matchesCategory = !category || event.category === category;

            const matchesStatus = !status || this.getEventStatusValue(event) === status;

            const matchesMonth = !month || event.startDate.startsWith(month);

            return matchesSearch && matchesCategory && matchesStatus && matchesMonth;
        });

        this.updateEventsList(filteredEvents);
    }

    getEventStatusValue(event) {
        const now = new Date();
        const startDate = new Date(event.startDate);
        const endDate = new Date(event.endDate);

        if (now < startDate) return 'upcoming';
        if (now > endDate) return 'past';
        return 'ongoing';
    }

    updateEventsList(filteredEvents) {
        const tbody = document.querySelector('tbody');
        tbody.innerHTML = filteredEvents.map(event => this.renderEventRow(event)).join('');
    }

    async showAddModal() {
        this.clearForm();
        document.getElementById('eventModalTitle').textContent = 'Add Event';
        const modal = new bootstrap.Modal(document.getElementById('eventModal'));
        modal.show();
    }

    async showEditModal(eventId) {
        const event = this.events.find(e => e.id === eventId);
        if (!event) return;

        document.getElementById('eventModalTitle').textContent = 'Edit Event';
        document.getElementById('eventId').value = event.id;
        document.getElementById('title').value = event.title;
        document.getElementById('category').value = event.category;
        document.getElementById('description').value = event.description || '';
        document.getElementById('startDate').value = this.formatDateTimeLocal(event.startDate);
        document.getElementById('endDate').value = this.formatDateTimeLocal(event.endDate);
        document.getElementById('location').value = event.location;
        document.getElementById('isRecurring').checked = event.isRecurring;
        document.getElementById('recurrenceRule').value = event.recurrenceRule || 'FREQ=WEEKLY';
        document.getElementById('requiresRegistration').checked = event.requiresRegistration;
        document.getElementById('maxAttendees').value = event.maxAttendees || '';

        // Show/hide optional sections
        document.getElementById('recurrenceOptions').style.display = 
            event.isRecurring ? 'block' : 'none';
        document.getElementById('registrationOptions').style.display = 
            event.requiresRegistration ? 'block' : 'none';

        if (event.imageUrl) {
            const previewContainer = document.getElementById('imagePreview');
            previewContainer.innerHTML = `
                <div class="mt-2">
                    <img src="${event.imageUrl}" 
                         alt="Current Image" 
                         style="max-width: 200px; max-height: 200px; object-fit: contain;"
                         class="border rounded">
                    <button type="button" 
                            class="btn btn-sm btn-outline-danger mt-1"
                            onclick="events.removeImage()">
                        Remove Image
                    </button>
                </div>
            `;
        }

        const modal = new bootstrap.Modal(document.getElementById('eventModal'));
        modal.show();
    }

    formatDateTimeLocal(dateString) {
        return new Date(dateString).toISOString().slice(0, 16);
    }

    clearForm() {
        document.getElementById('eventForm').reset();
        document.getElementById('eventId').value = '';
        document.getElementById('recurrenceOptions').style.display = 'none';
        document.getElementById('registrationOptions').style.display = 'none';
        document.getElementById('imagePreview').innerHTML = '';
    }

    async saveEvent() {
        try {
            const formData = new FormData();
            const eventId = document.getElementById('eventId').value;
            const imageFile = document.getElementById('imageFile').files[0];

            // Add form fields to FormData
            const fields = [
                'title', 'category', 'description', 'location',
                'startDate', 'endDate', 'isRecurring', 'recurrenceRule',
                'requiresRegistration', 'maxAttendees'
            ];

            fields.forEach(field => {
                const element = document.getElementById(field);
                if (element.type === 'checkbox') {
                    formData.append(field, element.checked);
                } else if (element.value) {
                    formData.append(field, element.value);
                }
            });

            if (imageFile) {
                formData.append('image_file', imageFile);
            }

            const url = eventId ? `/api/events/${eventId}` : '/api/events';
            const method = eventId ? 'PUT' : 'POST';

            const response = await fetch(url, {
                method: method,
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                },
                body: formData
            });

            if (!response.ok) {
                throw new Error('Failed to save event');
            }

            // Close modal and refresh list
            bootstrap.Modal.getInstance(document.getElementById('eventModal')).hide();
            await this.init();
            this.showSuccessToast(eventId ? 'Event updated successfully' : 'Event added successfully');
        } catch (error) {
            console.error('Error saving event:', error);
            this.showErrorToast('Failed to save event');
        }
    }

    confirmDelete(eventId) {
        this.eventToDelete = eventId;
        const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
        modal.show();
    }

    async deleteEvent() {
        try {
            const response = await fetch(`/api/events/${this.eventToDelete}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                }
            });

            if (!response.ok) {
                throw new Error('Failed to delete event');
            }

            // Close modal and refresh list
            bootstrap.Modal.getInstance(document.getElementById('deleteModal')).hide();
            await this.init();
            this.showSuccessToast('Event deleted successfully');
        } catch (error) {
            console.error('Error deleting event:', error);
            this.showErrorToast('Failed to delete event');
        }
    }

    showSuccessToast(message) {
        this.showToast(message, 'success');
    }

    showErrorToast(message) {
        this.showToast(message, 'danger');
    }

    showToast(message, type) {
        const toastContainer = document.createElement('div');
        toastContainer.style.position = 'fixed';
        toastContainer.style.top = '20px';
        toastContainer.style.right = '20px';
        toastContainer.style.zIndex = '1050';

        toastContainer.innerHTML = `
            <div class="toast align-items-center text-white bg-${type} border-0" role="alert">
                <div class="d-flex">
                    <div class="toast-body">
                        ${message}
                    </div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
                </div>
            </div>
        `;

        document.body.appendChild(toastContainer);
        const toast = new bootstrap.Toast(toastContainer.querySelector('.toast'));
        toast.show();

        toastContainer.querySelector('.toast').addEventListener('hidden.bs.toast', () => {
            document.body.removeChild(toastContainer);
        });
    }

    initImageHandlers() {
        const imageFile = document.getElementById('imageFile');
        const previewContainer = document.createElement('div');
        previewContainer.id = 'imagePreview';
        imageFile.parentNode.insertBefore(previewContainer, imageFile.nextSibling);

        imageFile.addEventListener('change', (e) => {
            this.previewImage(e.target.files[0]);
        });
    }

    previewImage(file) {
        const previewContainer = document.getElementById('imagePreview');
        previewContainer.innerHTML = '';

        if (!file) return;

        if (!this.validateImageFile(file)) {
            imageFile.value = '';
            return;
        }

        const reader = new FileReader();
        reader.onload = (e) => {
            const preview = document.createElement('div');
            preview.className = 'mt-2';
            preview.innerHTML = `
                <img src="${e.target.result}" 
                     alt="Preview" 
                     style="max-width: 200px; max-height: 200px; object-fit: contain;"
                     class="border rounded">
                <button type="button" 
                        class="btn btn-sm btn-outline-danger mt-1"
                        onclick="events.removeImage()">
                    Remove Image
                </button>
            `;
            previewContainer.appendChild(preview);
        };
        reader.readAsDataURL(file);
    }

    validateImageFile(file) {
        const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        const maxSize = 5 * 1024 * 1024; // 5MB

        if (!allowedTypes.includes(file.type)) {
            this.showErrorToast('Invalid file type. Please upload a JPEG, PNG, GIF, or WebP image.');
            return false;
        }

        if (file.size > maxSize) {
            this.showErrorToast('File size exceeds 5MB limit.');
            return false;
        }

        return true;
    }

    removeImage() {
        document.getElementById('imageFile').value = '';
        document.getElementById('imagePreview').innerHTML = '';
    }
}