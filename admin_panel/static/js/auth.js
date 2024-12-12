class Auth {
    static async login(username, password) {
        try {
            const response = await fetch('/api/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ username, password }),
            });
            
            if (!response.ok) {
                throw new Error('Login failed');
            }

            const data = await response.json();
            localStorage.setItem('token', data.token);
            return true;
        } catch (error) {
            console.error('Login error:', error);
            return false;
        }
    }

    static logout() {
        localStorage.removeItem('token');
        window.location.reload();
    }

    static isAuthenticated() {
        return !!localStorage.getItem('token');
    }

    static getLoginHTML() {
        return `
            <div class="login-container">
                <div class="card login-card">
                    <div class="card-body">
                        <h2 class="card-title text-center mb-4">Admin Login</h2>
                        <form id="loginForm">
                            <div class="mb-3">
                                <label for="username" class="form-label">Username</label>
                                <input type="text" class="form-control" id="username" required>
                            </div>
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="password" required>
                            </div>
                            <button type="submit" class="btn btn-primary w-100">Login</button>
                        </form>
                    </div>
                </div>
            </div>
        `;
    }

    static initLoginHandlers() {
        const form = document.getElementById('loginForm');
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            
            if (await Auth.login(username, password)) {
                window.location.reload();
            } else {
                alert('Login failed. Please try again.');
            }
        });
    }
} 