class App {
    constructor() {
        this.appElement = document.getElementById('app');
        this.currentPage = null;
        this.sermons = null;
        this.init();
    }

    init() {
        if (!Auth.isAuthenticated()) {
            this.showLogin();
        } else {
            this.showDashboard();
        }
    }

    showLogin() {
        this.appElement.innerHTML = Auth.getLoginHTML();
        Auth.initLoginHandlers();
    }

    showDashboard() {
        this.appElement.innerHTML = `
            <div class="container-fluid">
                <div class="row">
                    <!-- Sidebar -->
                    <nav class="col-md-3 col-lg-2 d-md-block sidebar collapse">
                        <div class="position-sticky pt-3">
                            <ul class="nav flex-column">
                                <li class="nav-item">
                                    <a class="nav-link active" href="#" data-page="dashboard">
                                        <i class="bi bi-speedometer2"></i> Dashboard
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#" data-page="sermons">
                                        <i class="bi bi-mic"></i> Sermons
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#" data-page="events">
                                        <i class="bi bi-calendar-event"></i> Events
                                    </a>
                                </li>
                                <li class="nav-item mt-3">
                                    <a class="nav-link" href="#" id="logoutBtn">
                                        <i class="bi bi-box-arrow-right"></i> Logout
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </nav>

                    <!-- Main content -->
                    <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
                        <div id="content"></div>
                    </main>
                </div>
            </div>
        `;

        this.initNavigationHandlers();
        this.loadPage('dashboard');
    }

    initNavigationHandlers() {
        const navLinks = document.querySelectorAll('.nav-link[data-page]');
        navLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const page = e.target.dataset.page;
                this.loadPage(page);
                
                // Update active state
                navLinks.forEach(l => l.classList.remove('active'));
                e.target.classList.add('active');
            });
        });

        document.getElementById('logoutBtn').addEventListener('click', (e) => {
            e.preventDefault();
            Auth.logout();
        });
    }

    loadPage(page) {
        const contentElement = document.getElementById('content');
        contentElement.innerHTML = '';

        switch (page) {
            case 'dashboard':
                new Dashboard(contentElement);
                break;
            case 'sermons':
                const sermonsContainer = document.createElement('div');
                sermonsContainer.id = 'sermonsContainer';
                contentElement.appendChild(sermonsContainer);
                this.sermons = new Sermons(sermonsContainer);
                break;
            case 'events':
                new Events(contentElement);
                break;
        }
    }
}

// Initialize the app when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.app = new App();
}); 