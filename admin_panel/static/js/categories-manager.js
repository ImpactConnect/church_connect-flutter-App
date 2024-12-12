class CategoriesManager {
    constructor(container) {
        this.container = container;
        this.categories = [];
        this.init();
    }

    async init() {
        await this.loadCategories();
        this.render();
    }

    async loadCategories() {
        const response = await fetch('/api/sermons/categories', {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
        });
        this.categories = await response.json();
    }

    render() {
        this.container.innerHTML = `
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Categories</h5>
                    <button class="btn btn-sm btn-primary" onclick="categoriesManager.showAddModal()">
                        <i class="bi bi-plus"></i> Add Category
                    </button>
                </div>
                <div class="card-body">
                    <div class="list-group">
                        ${this.renderCategories()}
                    </div>
                </div>
            </div>
            ${this.renderModals()}
        `;
    }

    renderCategories() {
        return this.categories.map(category => `
            <div class="list-group-item d-flex justify-content-between align-items-center">
                <span>${category.name}</span>
                <div class="btn-group">
                    <button class="btn btn-sm btn-outline-primary" onclick="categoriesManager.editCategory('${category.id}')">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-danger" onclick="categoriesManager.deleteCategory('${category.id}')">
                        <i class="bi bi-trash"></i>
                    </button>
                </div>
            </div>
        `).join('');
    }

    // ... Add category management methods
} 