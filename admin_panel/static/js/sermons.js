class Sermons {
    constructor(container) {
        this.container = container;
        this.sermons = [];
        this.init();
    }

    async init() {
        this.showLoading();
        try {
            await this.fetchSermons();
            this.render();
        } catch (error) {
            console.error('Sermons initialization error:', error);
            this.showError();
        }
    }

    async fetchSermons() {
        const response = await fetch('/api/sermons', {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
        });
        this.sermons = await response.json();
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
                Error loading sermons. Please try again later.
            </div>
        `;
    }

    render() {
        this.container.innerHTML = `
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Sermons</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" class="btn btn-primary" onclick="window.app.sermons.showAddModal()">
                        <i class="bi bi-plus"></i> Add Sermon
                    </button>
                </div>
            </div>
            <div class="table-responsive">
                <table class="table table-striped table-sm">
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Preacher</th>
                            <th>Category</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${this.renderSermons()}
                    </tbody>
                </table>
            </div>
            ${this.renderModals()}
        `;
    }

    renderSermons() {
        return this.sermons.map(sermon => `
            <tr>
                <td>${sermon.title}</td>
                <td>${sermon.preacher}</td>
                <td>${sermon.category}</td>
                <td>${new Date(sermon.date).toLocaleDateString()}</td>
                <td>
                    <button class="btn btn-sm btn-outline-secondary" onclick="window.app.sermons.showEditModal('${sermon.id}')">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="window.app.sermons.deleteSermon('${sermon.id}')">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    }

    renderModals() {
        return `
            <div class="modal fade" id="addSermonModal" tabindex="-1" aria-labelledby="addSermonModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="addSermonModalLabel">Add Sermon</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <form id="addSermonForm">
                                <div class="mb-3">
                                    <label for="title" class="form-label">Title</label>
                                    <input type="text" class="form-control" id="title" required>
                                </div>
                                <div class="mb-3">
                                    <label for="preacher" class="form-label">Preacher</label>
                                    <input type="text" class="form-control" id="preacher" required>
                                </div>
                                <div class="mb-3">
                                    <label for="category" class="form-label">Category</label>
                                    <input type="text" class="form-control" id="category" required>
                                </div>
                                <div class="mb-3">
                                    <label for="description" class="form-label">Description</label>
                                    <textarea class="form-control" id="description" rows="3"></textarea>
                                </div>
                                <div class="mb-3">
                                    <label for="audioUrl" class="form-label">Audio URL</label>
                                    <input type="text" class="form-control" id="audioUrl" required>
                                </div>
                                <div class="mb-3">
                                    <label for="date" class="form-label">Date</label>
                                    <input type="date" class="form-control" id="date" required>
                                </div>
                                <div class="mb-3">
                                    <label for="duration" class="form-label">Duration (minutes)</label>
                                    <input type="number" class="form-control" id="duration" required>
                                </div>
                                <div class="mb-3">
                                    <label for="topics" class="form-label">Topics</label>
                                    <input type="text" class="form-control" id="topics">
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" class="btn btn-primary" onclick="window.app.sermons.addSermon()">Save</button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }

    initEventListeners() {
        // Search functionality
        document.getElementById('searchSermon').addEventListener('input', (e) => {
            const searchTerm = e.target.value.toLowerCase();
            const rows = document.querySelectorAll('tbody tr');
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        });

        // Category filter
        document.getElementById('filterCategory').addEventListener('change', (e) => {
            const category = e.target.value;
            const rows = document.querySelectorAll('tbody tr');
            rows.forEach(row => {
                if (!category || row.children[2].textContent === category) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
    }

    getUniqueCategories() {
        return [...new Set(this.sermons.map(sermon => sermon.category))];
    }

    formatDate(dateString) {
        return new Date(dateString).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    }

    formatDuration(seconds) {
        const minutes = Math.floor(seconds / 60);
        return `${minutes} min`;
    }

    // Modal Management
    showAddModal() {
        const modal = new bootstrap.Modal(document.getElementById('addSermonModal'));
        modal.show();
    }

    async showEditModal(sermonId) {
        const sermon = this.sermons.find(s => s.id === sermonId);
        if (!sermon) return;

        document.getElementById('sermonModalTitle').textContent = 'Edit Sermon';
        document.getElementById('sermonId').value = sermon.id;
        document.getElementById('title').value = sermon.title;
        document.getElementById('preacher').value = sermon.preacher;
        document.getElementById('category').value = sermon.category;
        document.getElementById('topics').value = sermon.topics.join(', ');
        document.getElementById('description').value = sermon.description || '';
        document.getElementById('date').value = this.formatDateTimeLocal(sermon.date);
        document.getElementById('duration').value = Math.floor(sermon.duration / 60);

        const modal = new bootstrap.Modal(document.getElementById('sermonModal'));
        modal.show();
    }

    formatDateTimeLocal(dateString) {
        const date = new Date(dateString);
        return date.toISOString().slice(0, 16);
    }

    clearForm() {
        document.getElementById('sermonForm').reset();
        document.getElementById('sermonId').value = '';
    }

    // CRUD Operations
    async saveSermon() {
        try {
            const formData = new FormData();
            const sermonId = document.getElementById('sermonId').value;
            const audioFile = document.getElementById('audioFile').files[0];

            // Add form fields to FormData
            formData.append('title', document.getElementById('title').value);
            formData.append('preacher', document.getElementById('preacher').value);
            formData.append('category', document.getElementById('category').value);
            formData.append('topics', document.getElementById('topics').value);
            formData.append('description', document.getElementById('description').value);
            formData.append('date', document.getElementById('date').value);
            formData.append('duration', document.getElementById('duration').value * 60); // Convert to seconds

            if (audioFile) {
                formData.append('audio_file', audioFile);
            }

            const url = sermonId ? `/api/sermons/${sermonId}` : '/api/sermons';
            const method = sermonId ? 'PUT' : 'POST';

            const response = await fetch(url, {
                method: method,
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                },
                body: formData
            });

            if (!response.ok) {
                throw new Error('Failed to save sermon');
            }

            // Close modal and refresh list
            bootstrap.Modal.getInstance(document.getElementById('sermonModal')).hide();
            await this.init();
            this.showSuccessToast(sermonId ? 'Sermon updated successfully' : 'Sermon added successfully');
        } catch (error) {
            console.error('Error saving sermon:', error);
            this.showErrorToast('Failed to save sermon');
        }
    }

    confirmDelete(sermonId) {
        this.sermonToDelete = sermonId;
        const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
        modal.show();
    }

    async deleteSermon() {
        try {
            const response = await fetch(`/api/sermons/${this.sermonToDelete}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                }
            });

            if (!response.ok) {
                throw new Error('Failed to delete sermon');
            }

            // Close modal and refresh list
            bootstrap.Modal.getInstance(document.getElementById('deleteModal')).hide();
            await this.init();
            this.showSuccessToast('Sermon deleted successfully');
        } catch (error) {
            console.error('Error deleting sermon:', error);
            this.showErrorToast('Failed to delete sermon');
        }
    }

    // Toast Notifications
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

        // Remove the toast container after it's hidden
        toastContainer.querySelector('.toast').addEventListener('hidden.bs.toast', () => {
            document.body.removeChild(toastContainer);
        });
    }

    // Audio Preview
    previewAudio(url) {
        const audio = new Audio(url);
        audio.play();
    }

    // Validation
    validateForm() {
        const form = document.getElementById('sermonForm');
        return form.checkValidity();
    }

    initializeSearch() {
        this.searchManager = new SearchManager();
        const searchInput = document.getElementById('searchSermon');
        
        this.searchManager.init(searchInput, (results) => {
            this.updateSermonsList(results);
        });
    }

    initializeFilters() {
        const categoryFilter = document.getElementById('filterCategory');
        const topicFilter = document.getElementById('filterTopic');
        const dateFilter = document.getElementById('filterDate');

        categoryFilter.addEventListener('change', () => this.applyFilters());
        topicFilter.addEventListener('change', () => this.applyFilters());
        dateFilter.addEventListener('change', () => this.applyFilters());
    }

    applyFilters() {
        const category = document.getElementById('filterCategory').value;
        const topic = document.getElementById('filterTopic').value;
        const date = document.getElementById('filterDate').value;

        let filteredSermons = this.sermons;

        if (category) {
            filteredSermons = filteredSermons.filter(sermon => 
                sermon.category === category
            );
        }

        if (topic) {
            filteredSermons = filteredSermons.filter(sermon => 
                sermon.topics.includes(topic)
            );
        }

        if (date) {
            const selectedDate = new Date(date);
            filteredSermons = filteredSermons.filter(sermon => {
                const sermonDate = new Date(sermon.date);
                return sermonDate.toDateString() === selectedDate.toDateString();
            });
        }

        this.updateSermonsList(filteredSermons);
    }

    async handleFileUpload(input) {
        const file = input.files[0];
        if (!file) return;

        try {
            FileHandler.validateAudioFile(file);
            
            const progressBar = document.getElementById('uploadProgress');
            progressBar.style.width = '0%';
            progressBar.parentElement.style.display = 'block';

            await FileHandler.uploadFile(file, (progress) => {
                progressBar.style.width = `${progress}%`;
            });

            progressBar.parentElement.style.display = 'none';
            this.showSuccessToast('File uploaded successfully');
        } catch (error) {
            this.showErrorToast(error.message);
            input.value = ''; // Clear the file input
        }
    }

    async addSermon() {
        const title = document.getElementById('title').value;
        const preacher = document.getElementById('preacher').value;
        const category = document.getElementById('category').value;
        const description = document.getElementById('description').value;
        const audioUrl = document.getElementById('audioUrl').value;
        const date = document.getElementById('date').value;
        const duration = parseInt(document.getElementById('duration').value) * 60; // Convert to seconds
        const topics = document.getElementById('topics').value.split(',').map(topic => topic.trim());

        const formData = new FormData();
        formData.append('title', title);
        formData.append('preacher', preacher);
        formData.append('category', category);
        formData.append('description', description);
        formData.append('audioUrl', audioUrl);
        formData.append('date', date);
        formData.append('duration', duration);
        formData.append('topics', topics.join(','));

        try {
            const response = await fetch('/api/sermons', {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                },
                body: formData
            });

            if (response.ok) {
                // Sermon added successfully
                const modal = bootstrap.Modal.getInstance(document.getElementById('addSermonModal'));
                modal.hide();
                await this.fetchSermons();
                this.render();
            } else {
                // Handle error
                console.error('Error adding sermon:', response.statusText);
                alert('Error adding sermon. Please try again.');
            }
        } catch (error) {
            console.error('Error adding sermon:', error);
            alert('Error adding sermon. Please try again.');
        }
    }
} 