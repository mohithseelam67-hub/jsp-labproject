<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
    <title>MyPad — Simple Shared Text & Notes</title>
    <meta name="description" content="Create, edit, and collaborate in real-time by simply navigating to any URL. No accounts, no invitations, and zero complicated setup.">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
</head>
<body data-context-path="<%= request.getContextPath() %>">

    <%@ include file="includes/navbar.jsp" %>

    <main class="main-wrapper">
        <section class="hero-section">
            <h1 class="hero-title">Simple shared text, instantly.</h1>
            <p class="hero-desc">
                Create, edit, and collaborate in real-time by simply navigating to any URL. No accounts, no invitations, and zero complicated setup.
            </p>

            <div class="tab-container">
                <!-- Mode Switcher Tabs -->
                <div class="tab-switcher" role="tablist" aria-label="Pad mode selection">
                    <button type="button" id="tabInstantBtn" class="tab-btn active" onclick="switchTab('instant')">
                        Instant Pad (No login)
                    </button>
                    <button type="button" id="tabSearchBtn" class="tab-btn" onclick="switchTab('search')">
                        Search Public Pads
                    </button>
                </div>

                <!-- Instant Pad Panel -->
                <div id="instantPanel">
                    <form id="openPadForm" onsubmit="handleOpenPad(event)">
                        <label for="padInput" class="input-group-label">Desired pad name or nested path</label>
                        <div class="input-box">
                            <input 
                                type="text" 
                                id="padInput" 
                                placeholder="/notes/standup/project" 
                                autocomplete="off" 
                                autocorrect="off" 
                                autocapitalize="off" 
                                spellcheck="false"
                            />
                            <button type="submit" class="btn btn-primary">
                                Open Pad
                            </button>
                        </div>
                    </form>

                    <!-- Suggestions -->
                    <div class="suggestions-row">
                        <span class="suggestions-label">Suggestions:</span>
                        <button type="button" class="suggestion-pill" onclick="pickSuggestion('/notes')">/notes</button>
                        <button type="button" class="suggestion-pill" onclick="pickSuggestion('/standup')">/standup</button>
                        <button type="button" class="suggestion-pill" onclick="pickSuggestion('/project')">/project</button>
                        <button type="button" class="suggestion-pill" onclick="pickSuggestion('/api')">/api</button>
                        <button type="button" class="suggestion-pill" onclick="pickSuggestion('/college')">/college</button>
                        <button type="button" class="suggestion-pill" onclick="pickSuggestion('/math')">/math</button>
                    </div>
                </div>

                <!-- Search Public Pads Panel -->
                <div id="searchPanel" style="display: none;">
                    <div style="position: relative;">
                        <label for="searchInput" class="input-group-label">Search by pad name, content, or @username</label>
                        <div class="input-box">
                            <input 
                                type="text" 
                                id="searchInput" 
                                placeholder="e.g. /notes or @john" 
                                autocomplete="off" 
                                spellcheck="false"
                                oninput="handleSearchInput()"
                                onkeydown="handleSearchKeyDown(event)"
                            />
                            <button type="button" class="btn btn-primary" onclick="performSearch()">
                                Search
                            </button>
                        </div>

                        <!-- Autocomplete Dropdown for @username -->
                        <div id="autocompleteDropdown" class="autocomplete-dropdown" style="display: none;"></div>
                    </div>

                    <!-- Search Results Output -->
                    <div id="searchResults" class="search-results-list"></div>
                </div>
            </div>
        </section>
    </main>

    <%@ include file="includes/footer.jsp" %>

    <script>
        const CTX = document.body.dataset.contextPath || '';
        let currentTab = 'instant';
        let searchDebounceTimer = null;
        let autocompleteDebounceTimer = null;

        function switchTab(tab) {
            currentTab = tab;
            const tabInstantBtn = document.getElementById('tabInstantBtn');
            const tabSearchBtn = document.getElementById('tabSearchBtn');
            const instantPanel = document.getElementById('instantPanel');
            const searchPanel = document.getElementById('searchPanel');

            if (tab === 'instant') {
                tabInstantBtn.classList.add('active');
                tabSearchBtn.classList.remove('active');
                instantPanel.style.display = 'block';
                searchPanel.style.display = 'none';
                document.getElementById('padInput').focus();
            } else {
                tabSearchBtn.classList.add('active');
                tabInstantBtn.classList.remove('active');
                instantPanel.style.display = 'none';
                searchPanel.style.display = 'block';
                document.getElementById('searchInput').focus();
            }
        }

        function pickSuggestion(path) {
            const input = document.getElementById('padInput');
            input.value = path;
            navigateToPad(path);
        }

        function handleOpenPad(e) {
            e.preventDefault();
            const input = document.getElementById('padInput');
            let path = input.value.trim();
            if (!path) {
                path = '/notes';
            }
            navigateToPad(path);
        }

        function navigateToPad(path) {
            if (!path.startsWith('/')) {
                path = '/' + path;
            }
            window.location.href = CTX + '/pad.jsp?path=' + encodeURIComponent(path);
        }

        // Search & Autocomplete
        function handleSearchInput() {
            const val = document.getElementById('searchInput').value.trim();
            const dropdown = document.getElementById('autocompleteDropdown');

            clearTimeout(autocompleteDebounceTimer);
            clearTimeout(searchDebounceTimer);

            if (val.startsWith('@') && !val.includes('/')) {
                // Trigger @username autocomplete
                autocompleteDebounceTimer = setTimeout(() => {
                    fetchAutocomplete(val);
                }, 200);
            } else {
                dropdown.style.display = 'none';
                // Trigger auto search if length >= 2
                if (val.length >= 2) {
                    searchDebounceTimer = setTimeout(() => {
                        performSearch();
                    }, 400);
                } else if (val.length === 0) {
                    document.getElementById('searchResults').innerHTML = '';
                }
            }
        }

        async function fetchAutocomplete(query) {
            const dropdown = document.getElementById('autocompleteDropdown');
            try {
                const res = await fetch(CTX + '/api/user/autocomplete.jsp?q=' + encodeURIComponent(query));
                const data = await res.json();
                if (data.suggestions && data.suggestions.length > 0) {
                    dropdown.innerHTML = '';
                    data.suggestions.forEach(uname => {
                        const div = document.createElement('div');
                        div.className = 'autocomplete-item';
                        div.innerHTML = '<span>@' + uname + '</span>';
                        div.onclick = () => {
                            document.getElementById('searchInput').value = '@' + uname;
                            dropdown.style.display = 'none';
                            performSearch();
                        };
                        dropdown.appendChild(div);
                    });
                    dropdown.style.display = 'block';
                } else {
                    dropdown.style.display = 'none';
                }
            } catch (err) {
                dropdown.style.display = 'none';
            }
        }

        async function performSearch() {
            const val = document.getElementById('searchInput').value.trim();
            const resultsContainer = document.getElementById('searchResults');
            const dropdown = document.getElementById('autocompleteDropdown');
            dropdown.style.display = 'none';

            if (!val) {
                resultsContainer.innerHTML = '';
                return;
            }

            resultsContainer.innerHTML = '<div style="font-size: 0.85rem; color: var(--text-muted); text-align: center; padding: 1rem;">Searching pads...</div>';

            try {
                const res = await fetch(CTX + '/api/pads/search.jsp?q=' + encodeURIComponent(val));
                const data = await res.json();

                if (!data.pads || data.pads.length === 0) {
                    resultsContainer.innerHTML = '<div style="font-size: 0.85rem; color: var(--text-muted); text-align: center; padding: 1.5rem; background: var(--bg-card); border: 1px dashed var(--border-color); border-radius: 8px;">No public pads found for "' + val + '". You can <a href="' + CTX + '/pad.jsp?path=' + encodeURIComponent(val.startsWith('/') ? val : '/' + val) + '" style="color: var(--text-primary); text-decoration: underline; font-weight: 500;">create this pad now &rarr;</a></div>';
                    return;
                }

                resultsContainer.innerHTML = '';
                data.pads.forEach(pad => {
                    const card = document.createElement('div');
                    card.className = 'search-item-card';
                    card.onclick = () => {
                        window.location.href = CTX + '/pad.jsp?path=' + encodeURIComponent(pad.path);
                    };

                    const updatedDate = pad.updatedAt ? new Date(pad.updatedAt).toLocaleDateString() : 'Recently';
                    const ownerTag = pad.ownerUsername ? ' &bull; by @' + pad.ownerUsername : '';

                    card.innerHTML = 
                        '<div class="search-item-header">' +
                            '<span class="search-item-path">' + pad.path + '</span>' +
                            '<span class="search-item-meta">' + pad.wordCount + ' words &bull; ' + updatedDate + ownerTag + '</span>' +
                        '</div>' +
                        '<div class="search-item-snippet">' + (pad.snippet || '<em style="color: var(--text-muted);">Empty pad</em>') + '</div>';

                    resultsContainer.appendChild(card);
                });
            } catch (err) {
                resultsContainer.innerHTML = '<div style="font-size: 0.85rem; color: var(--danger); text-align: center; padding: 1rem;">Failed to load search results: ' + err.message + '</div>';
            }
        }

        function handleSearchKeyDown(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                performSearch();
            }
        }

        // Close dropdown when clicking outside
        document.addEventListener('click', (e) => {
            const dropdown = document.getElementById('autocompleteDropdown');
            if (dropdown && !e.target.closest('#searchPanel')) {
                dropdown.style.display = 'none';
            }
        });
    </script>
</body>
</html>