class Dashboard {
    constructor(container) {
        this.container = container;
        this.init();
    }

    async init() {
        this.showLoading();
        try {
            const stats = await this.fetchDashboardStats();
            const recentSermons = await this.fetchRecentSermons();
            const upcomingEvents = await this.fetchUpcomingEvents();
            this.render(stats, recentSermons, upcomingEvents);
        } catch (error) {
            console.error('Dashboard initialization error:', error);
            this.showError();
        }
    }

    async fetchDashboardStats() {
        const response = await fetch('/api/dashboard/stats', {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
        });
        return await response.json();
    }

    async fetchRecentSermons() {
        const response = await fetch('/api/sermons/recent', {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
        });
        return await response.json();
    }

    async fetchUpcomingEvents() {
        const response = await fetch('/api/events/upcoming', {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
        });
        return await response.json();
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
                Error loading dashboard data. Please try again later.
            </div>
        `;
    }

    render(stats, recentSermons, upcomingEvents) {
        this.container.innerHTML = `
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Dashboard</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" class="btn btn-sm btn-outline-secondary" id="refreshDashboard">
                        <i class="bi bi-arrow-clockwise"></i> Refresh
                    </button>
                </div>
            </div>

            <!-- Statistics Cards -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card text-white bg-primary">
                        <div class="card-body">
                            <h5 class="card-title">Total Sermons</h5>
                            <h2 class="card-text">${stats.totalSermons}</h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-success">
                        <div class="card-body">
                            <h5 class="card-title">Upcoming Events</h5>
                            <h2 class="card-text">${stats.upcomingEvents}</h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-info">
                        <div class="card-body">
                            <h5 class="card-title">Total Downloads</h5>
                            <h2 class="card-text">${stats.totalDownloads}</h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-warning">
                        <div class="card-body">
                            <h5 class="card-title">Active Users</h5>
                            <h2 class="card-text">${stats.activeUsers}</h2>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <!-- Recent Sermons -->
                <div class="col-md-6 mb-4">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Recent Sermons</h5>
                        </div>
                        <div class="card-body">
                            <div class="list-group list-group-flush">
                                ${this.renderRecentSermons(recentSermons)}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Upcoming Events -->
                <div class="col-md-6 mb-4">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Upcoming Events</h5>
                        </div>
                        <div class="card-body">
                            <div class="list-group list-group-flush">
                                ${this.renderUpcomingEvents(upcomingEvents)}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        // Add event listeners
        document.getElementById('refreshDashboard').addEventListener('click', () => {
            this.init();
        });
    }

    renderRecentSermons(sermons) {
        return sermons.map(sermon => `
            <div class="list-group-item">
                <div class="d-flex w-100 justify-content-between">
                    <h6 class="mb-1">${sermon.title}</h6>
                    <small class="text-muted">${this.formatDate(sermon.date)}</small>
                </div>
                <p class="mb-1">${sermon.preacher}</p>
                <small class="text-muted">${sermon.category}</small>
            </div>
        `).join('');
    }

    renderUpcomingEvents(events) {
        return events.map(event => `
            <div class="list-group-item">
                <div class="d-flex w-100 justify-content-between">
                    <h6 class="mb-1">${event.title}</h6>
                    <small class="text-muted">${this.formatDate(event.startDate)}</small>
                </div>
                <p class="mb-1">${event.location}</p>
                <small class="text-muted">
                    ${event.requiresRegistration ? 
                        `${event.currentAttendees}/${event.maxAttendees} registered` : 
                        'No registration required'}
                </small>
            </div>
        `).join('');
    }

    formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        });
    }
} 