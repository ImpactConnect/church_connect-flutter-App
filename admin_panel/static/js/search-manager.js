class SearchManager {
    constructor(options = {}) {
        this.searchDelay = options.searchDelay || 300;
        this.minSearchLength = options.minSearchLength || 2;
        this.searchTimer = null;
        this.lastSearch = '';
    }

    init(searchInput, callback) {
        searchInput.addEventListener('input', (e) => {
            const searchTerm = e.target.value.trim();

            if (searchTerm === this.lastSearch) return;
            this.lastSearch = searchTerm;

            clearTimeout(this.searchTimer);

            if (searchTerm.length < this.minSearchLength) {
                callback([]);
                return;
            }

            this.searchTimer = setTimeout(() => {
                this.performSearch(searchTerm, callback);
            }, this.searchDelay);
        });
    }

    async performSearch(term, callback) {
        try {
            const response = await fetch(`/api/sermons/search?q=${encodeURIComponent(term)}`, {
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                }
            });
            const results = await response.json();
            callback(results);
        } catch (error) {
            console.error('Search error:', error);
            callback([]);
        }
    }
} 