<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.mypad.config.MongoConfig" %>
<%@ page import="com.mypad.dao.PadDao" %>
<%
    boolean dbConnected = false;
    String dbName = "mypad_jsp";
    try {
        PadDao dao = new PadDao();
        dbConnected = dao.ping();
        dbName = MongoConfig.getDatabaseName();
    } catch (Exception e) {
        dbConnected = false;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MyPad - Shared Online Notepad</title>
    <style>
        :root {
            --bg-color: #0d1117;
            --surface: #161b22;
            --surface-hover: #21262d;
            --border: #30363d;
            --text-main: #f0f6fc;
            --text-muted: #8b949e;
            --primary: #238636;
            --primary-hover: #2ea043;
            --accent: #58a6ff;
            --warning: #d29922;
            --danger: #f85149;
            --font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            --font-mono: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: var(--font-family);
            background: var(--bg-color);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            padding: 24px;
        }

        .header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
            margin-bottom: 24px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-badge {
            background: linear-gradient(135deg, #1f6feb, #8957e5);
            color: white;
            font-weight: 700;
            font-size: 1.1rem;
            padding: 6px 12px;
            border-radius: 8px;
        }

        .brand h1 {
            font-size: 1.4rem;
            font-weight: 600;
        }

        .db-status {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 0.85rem;
            padding: 6px 12px;
            border-radius: 20px;
            background: var(--surface);
            border: 1px solid var(--border);
        }

        .status-dot {
            width: 9px;
            height: 9px;
            border-radius: 50%;
            background-color: var(--text-muted);
        }

        .status-dot.connected {
            background-color: var(--primary);
            box-shadow: 0 0 8px var(--primary);
        }

        .status-dot.disconnected {
            background-color: var(--danger);
            box-shadow: 0 0 8px var(--danger);
        }

        .main-container {
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 24px;
            flex: 1;
        }

        @media (max-width: 900px) {
            .main-container {
                grid-template-columns: 1fr;
            }
        }

        .editor-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
        }

        .path-bar {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 14px 18px;
            background: rgba(255, 255, 255, 0.02);
            border-bottom: 1px solid var(--border);
        }

        .path-label {
            font-weight: 600;
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        .path-input {
            flex: 1;
            background: var(--bg-color);
            border: 1px solid var(--border);
            color: var(--accent);
            font-family: var(--font-mono);
            font-size: 1rem;
            padding: 8px 14px;
            border-radius: 6px;
            outline: none;
            transition: border-color 0.2s;
        }

        .path-input:focus {
            border-color: var(--accent);
        }

        .btn {
            background: var(--primary);
            color: white;
            border: none;
            padding: 8px 16px;
            font-size: 0.9rem;
            font-weight: 500;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn:hover {
            background: var(--primary-hover);
        }

        .btn-secondary {
            background: var(--surface-hover);
            border: 1px solid var(--border);
            color: var(--text-main);
        }

        .btn-secondary:hover {
            background: #2d333b;
        }

        .meta-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 18px;
            background: rgba(0, 0, 0, 0.2);
            font-size: 0.8rem;
            color: var(--text-muted);
            border-bottom: 1px solid var(--border);
        }

        .meta-item strong {
            color: var(--text-main);
        }

        .textarea-container {
            flex: 1;
            display: flex;
            min-height: 420px;
        }

        textarea {
            width: 100%;
            height: 100%;
            background: transparent;
            border: none;
            color: var(--text-main);
            font-family: var(--font-mono);
            font-size: 0.95rem;
            line-height: 1.6;
            padding: 18px;
            resize: none;
            outline: none;
        }

        .sidebar {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .panel {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 16px;
        }

        .panel-title {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .children-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 6px;
            max-height: 220px;
            overflow-y: auto;
        }

        .child-item {
            padding: 6px 10px;
            background: var(--bg-color);
            border: 1px solid var(--border);
            border-radius: 6px;
            font-family: var(--font-mono);
            font-size: 0.85rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.2s;
        }

        .child-item:hover {
            border-color: var(--accent);
            color: var(--accent);
        }

        .badge-type {
            font-size: 0.7rem;
            padding: 2px 6px;
            border-radius: 4px;
            background: rgba(255, 255, 255, 0.08);
            color: var(--text-muted);
        }

        .api-docs pre {
            background: var(--bg-color);
            border: 1px solid var(--border);
            border-radius: 6px;
            padding: 8px 10px;
            font-family: var(--font-mono);
            font-size: 0.75rem;
            overflow-x: auto;
            color: #7ee787;
            margin-bottom: 8px;
        }

        .save-indicator {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.8rem;
            color: var(--text-muted);
        }

        .save-indicator.saving {
            color: var(--warning);
        }

        .save-indicator.saved {
            color: var(--primary);
        }

        .save-indicator.error {
            color: var(--danger);
        }
    </style>
</head>
<body data-api-base="<%= request.getContextPath() %>/api">

    <header class="header">
        <div class="brand">
            <span class="logo-badge">MyPad</span>
            <h1>Shared Online Notepad</h1>
        </div>
        <div class="db-status">
            <span class="status-dot <%= dbConnected ? "connected" : "disconnected" %>"></span>
            <span>MongoDB: <%= dbConnected ? "Connected (" + dbName + ")" : "Disconnected" %></span>
        </div>
    </header>

    <main class="main-container">
        <!-- Pad Editor Section -->
        <section class="editor-card">
            <div class="path-bar">
                <span class="path-label">Pad Path:</span>
                <input type="text" id="padPath" class="path-input" value="/college/ml" placeholder="/your/unique/path" spellcheck="false" />
                <button id="btnLoad" class="btn btn-secondary">Open Pad</button>
                <button id="btnSave" class="btn">Save</button>
            </div>

            <div class="meta-bar">
                <div class="meta-item">
                    Version: <strong id="padVersion">1</strong>
                </div>
                <div class="meta-item">
                    Last Updated: <span id="padUpdated">-</span>
                </div>
                <div id="saveIndicator" class="save-indicator">
                    <span>Ready</span>
                </div>
            </div>

            <div class="textarea-container">
                <textarea id="padContent" placeholder="Write or paste your notes here... Supports multiline, code snippets, and Unicode." spellcheck="false"></textarea>
            </div>
        </section>

        <!-- Sidebar Section -->
        <aside class="sidebar">
            <div class="panel">
                <div class="panel-title">
                    <span>Immediate Children</span>
                    <button id="btnRefreshChildren" class="btn btn-secondary" style="padding: 2px 8px; font-size: 0.75rem;">Refresh</button>
                </div>
                <ul id="childrenList" class="children-list">
                    <li style="color: var(--text-muted); font-size: 0.85rem;">Load a pad to view nested pads</li>
                </ul>
            </div>

            <div class="panel api-docs">
                <div class="panel-title">Backend API Endpoints</div>
                <div style="font-size: 0.8rem; color: var(--text-muted); margin-bottom: 8px;">1. Get or Create Pad:</div>
                <pre>GET /MyPadBackend/api/pad.jsp?path=/college/ml</pre>

                <div style="font-size: 0.8rem; color: var(--text-muted); margin-bottom: 8px;">2. Save Pad:</div>
                <pre>POST /MyPadBackend/api/save.jsp
{"path":"/college/ml","content":"...","version":1}</pre>

                <div style="font-size: 0.8rem; color: var(--text-muted); margin-bottom: 8px;">3. List Children:</div>
                <pre>GET /MyPadBackend/api/children.jsp?path=/college</pre>

                <div style="font-size: 0.8rem; color: var(--text-muted); margin-bottom: 8px;">4. Health Check:</div>
                <pre>GET /MyPadBackend/api/health.jsp</pre>
            </div>
        </aside>
    </main>

    <script>
        const API_BASE = document.body.dataset.apiBase || '/MyPadBackend/api';
        const pathInput = document.getElementById('padPath');
        const contentInput = document.getElementById('padContent');
        const versionEl = document.getElementById('padVersion');
        const updatedEl = document.getElementById('padUpdated');
        const indicator = document.getElementById('saveIndicator');
        const childrenList = document.getElementById('childrenList');

        let currentPad = {
            path: '/college/ml',
            version: 1,
            content: ''
        };

        let autoSaveTimer = null;

        function setStatus(text, state) {
            indicator.className = 'save-indicator ' + state;
            indicator.innerHTML = '<span>' + text + '</span>';
        }

        async function loadPad(path) {
            try {
                setStatus('Loading...', 'saving');
                const res = await fetch(API_BASE + '/pad.jsp?path=' + encodeURIComponent(path));
                const data = await res.json();
                if (!res.ok) {
                    throw new Error(data.error || 'Failed to load pad');
                }

                currentPad = data;
                pathInput.value = data.path;
                contentInput.value = data.content || '';
                versionEl.textContent = data.version;
                updatedEl.textContent = data.updatedAt ? new Date(data.updatedAt).toLocaleString() : 'Just now';
                setStatus('Loaded', 'saved');
                loadChildren(data.path);
            } catch (err) {
                setStatus('Error: ' + err.message, 'error');
            }
        }

        async function savePad() {
            const path = pathInput.value.trim();
            const content = contentInput.value;
            if (!path) return;

            try {
                setStatus('Saving...', 'saving');
                const res = await fetch(API_BASE + '/save.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json;charset=UTF-8' },
                    body: JSON.stringify({
                        path: path,
                        content: content,
                        version: currentPad.version
                    })
                });

                const data = await res.json();
                if (res.status === 409) {
                    setStatus('Conflict detected! Reloading...', 'error');
                    alert('Version conflict: another user updated this pad. The editor will now reload the latest version.');
                    loadPad(path);
                    return;
                }

                if (!res.ok) {
                    throw new Error(data.error || 'Save failed');
                }

                currentPad = data;
                versionEl.textContent = data.version;
                updatedEl.textContent = new Date(data.updatedAt).toLocaleString();
                setStatus('Saved', 'saved');
            } catch (err) {
                setStatus('Save failed: ' + err.message, 'error');
            }
        }

        async function loadChildren(parentPath) {
            try {
                const res = await fetch(API_BASE + '/children.jsp?path=' + encodeURIComponent(parentPath));
                const data = await res.json();
                if (!res.ok) return;

                childrenList.innerHTML = '';
                if (!data.children || data.children.length === 0) {
                    childrenList.innerHTML = '<li style="color: var(--text-muted); font-size: 0.85rem;">No child pads yet under ' + data.parentPath + '</li>';
                    return;
                }

                data.children.forEach(child => {
                    const li = document.createElement('li');
                    li.className = 'child-item';
                    li.innerHTML = '<span>' + child.name + '</span> <span class="badge-type">' + (child.isPad ? 'Pad v' + child.version : 'Branch') + '</span>';
                    li.onclick = () => {
                        pathInput.value = child.path;
                        loadPad(child.path);
                    };
                    childrenList.appendChild(li);
                });
            } catch (e) {
                console.error(e);
            }
        }

        // Event listeners
        document.getElementById('btnLoad').addEventListener('click', () => loadPad(pathInput.value));
        document.getElementById('btnSave').addEventListener('click', savePad);
        document.getElementById('btnRefreshChildren').addEventListener('click', () => loadChildren(currentPad.path));

        pathInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') loadPad(pathInput.value);
        });

        // Debounced auto-save
        contentInput.addEventListener('input', () => {
            setStatus('Typing...', 'saving');
            clearTimeout(autoSaveTimer);
            autoSaveTimer = setTimeout(() => {
                savePad();
            }, 1200);
        });

        // Initial load
        window.addEventListener('DOMContentLoaded', () => {
            loadPad(pathInput.value);
        });
    </script>
</body>
</html>