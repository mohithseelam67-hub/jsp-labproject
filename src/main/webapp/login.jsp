<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String existingUsername = (String) session.getAttribute("username");
    if (existingUsername != null && !existingUsername.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }
    String redirectUrl = request.getParameter("redirect");
    if (redirectUrl == null || redirectUrl.trim().isEmpty()) {
        redirectUrl = request.getContextPath() + "/dashboard.jsp";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In / Register — MyPad</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
    <style>
        .auth-container {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem 1.25rem;
        }
        .auth-tab-switch {
            display: grid;
            grid-template-columns: 1fr 1fr;
            background: var(--pill-bg);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 3px;
            margin-bottom: 1.5rem;
        }
        .auth-tab-btn {
            border: none;
            background: transparent;
            padding: 0.5rem;
            font-size: 0.85rem;
            font-weight: 500;
            color: var(--pill-text);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .auth-tab-btn.active {
            background: var(--pill-active-bg);
            color: var(--pill-active-text);
            box-shadow: var(--shadow-sm);
            font-weight: 600;
        }
    </style>
</head>
<body data-context-path="<%= request.getContextPath() %>" data-redirect-url="<%= redirectUrl %>">

    <%@ include file="includes/navbar.jsp" %>

    <main class="auth-container">
        <div class="auth-wrapper">
            <div class="auth-header">
                <div class="logo-box" style="margin: 0 auto; width: 2.25rem; height: 2.25rem; font-size: 1rem;">M</div>
                <h2 id="authHeading">Welcome to MyPad</h2>
                <p id="authSubheading">Sign in to manage your private pads and workspaces.</p>
            </div>

            <!-- Mode Switch: Sign In vs Sign Up -->
            <div class="auth-tab-switch" role="tablist">
                <button type="button" id="tabBtnSignIn" class="auth-tab-btn active" onclick="switchAuthMode('signin')">Sign In</button>
                <button type="button" id="tabBtnSignUp" class="auth-tab-btn" onclick="switchAuthMode('signup')">Create Account</button>
            </div>

            <!-- Notification Banner -->
            <div id="authAlert" class="alert" style="display: none;"></div>

            <!-- Sign In Form -->
            <form id="signInForm" onsubmit="handleSignIn(event)">
                <div class="form-group">
                    <label class="form-label" for="loginIdentifier">Email or Username</label>
                    <input type="text" id="loginIdentifier" class="form-control" placeholder="name@example.com or @username" required autocomplete="username" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="loginPassword">Password</label>
                    <input type="password" id="loginPassword" class="form-control" placeholder="••••••••" required autocomplete="current-password" />
                </div>
                <button type="submit" id="btnSubmitLogin" class="btn btn-primary" style="width: 100%; margin-top: 0.5rem; padding: 0.65rem;">
                    Sign In
                </button>
            </form>

            <!-- Sign Up Form -->
            <form id="signUpForm" onsubmit="handleSignUp(event)" style="display: none;">
                <div class="form-group">
                    <label class="form-label" for="regEmail">Email Address</label>
                    <input type="email" id="regEmail" class="form-control" placeholder="name@example.com" required autocomplete="email" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="regUsername">Choose a Username</label>
                    <input type="text" id="regUsername" class="form-control" placeholder="e.g. johndoe" required autocomplete="username" spellcheck="false" />
                    <span style="font-size: 0.72rem; color: var(--text-muted); font-family: var(--font-mono);">3-30 letters, numbers, hyphens or underscores</span>
                </div>
                <div class="form-group">
                    <label class="form-label" for="regPassword">Password</label>
                    <input type="password" id="regPassword" class="form-control" placeholder="At least 6 characters" required autocomplete="new-password" />
                </div>
                <div class="form-group">
                    <label class="form-label" for="regConfirmPassword">Confirm Password</label>
                    <input type="password" id="regConfirmPassword" class="form-control" placeholder="Repeat your password" required autocomplete="new-password" />
                </div>
                <button type="submit" id="btnSubmitRegister" class="btn btn-primary" style="width: 100%; margin-top: 0.5rem; padding: 0.65rem;">
                    Create Account
                </button>
            </form>
        </div>
    </main>

    <%@ include file="includes/footer.jsp" %>

    <script>
        const CTX = document.body.dataset.contextPath || '';
        const REDIRECT = document.body.dataset.redirectUrl || (CTX + '/dashboard.jsp');
        let currentMode = 'signin';

        function showAlert(msg, isError) {
            const alert = document.getElementById('authAlert');
            alert.className = 'alert ' + (isError ? 'alert-danger' : 'alert-success');
            alert.textContent = msg;
            alert.style.display = 'block';
        }

        function hideAlert() {
            document.getElementById('authAlert').style.display = 'none';
        }

        function switchAuthMode(mode) {
            currentMode = mode;
            hideAlert();
            const btnSignIn = document.getElementById('tabBtnSignIn');
            const btnSignUp = document.getElementById('tabBtnSignUp');
            const signInForm = document.getElementById('signInForm');
            const signUpForm = document.getElementById('signUpForm');
            const heading = document.getElementById('authHeading');
            const subheading = document.getElementById('authSubheading');

            if (mode === 'signin') {
                btnSignIn.classList.add('active');
                btnSignUp.classList.remove('active');
                signInForm.style.display = 'block';
                signUpForm.style.display = 'none';
                heading.textContent = 'Welcome to MyPad';
                subheading.textContent = 'Sign in to manage your private pads and workspaces.';
                document.getElementById('loginIdentifier').focus();
            } else {
                btnSignUp.classList.add('active');
                btnSignIn.classList.remove('active');
                signInForm.style.display = 'none';
                signUpForm.style.display = 'block';
                heading.textContent = 'Create your account';
                subheading.textContent = 'Claim your username and start saving personal pads.';
                document.getElementById('regEmail').focus();
            }
        }

        async function handleSignIn(e) {
            e.preventDefault();
            hideAlert();
            const identifier = document.getElementById('loginIdentifier').value.trim();
            const password = document.getElementById('loginPassword').value;
            const btn = document.getElementById('btnSubmitLogin');

            btn.disabled = true;
            btn.textContent = 'Signing in...';

            try {
                const res = await fetch(CTX + '/api/auth/login.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json;charset=UTF-8' },
                    body: JSON.stringify({ identifier, password })
                });

                const data = await res.json();
                if (!res.ok || !data.success) {
                    throw new Error(data.error || 'Invalid credentials');
                }

                showAlert('Sign in successful! Redirecting...', false);
                setTimeout(() => {
                    window.location.href = REDIRECT;
                }, 400);
            } catch (err) {
                showAlert(err.message, true);
                btn.disabled = false;
                btn.textContent = 'Sign In';
            }
        }

        async function handleSignUp(e) {
            e.preventDefault();
            hideAlert();
            const email = document.getElementById('regEmail').value.trim();
            const username = document.getElementById('regUsername').value.trim();
            const password = document.getElementById('regPassword').value;
            const confirm = document.getElementById('regConfirmPassword').value;
            const btn = document.getElementById('btnSubmitRegister');

            if (password !== confirm) {
                showAlert('Passwords do not match.', true);
                return;
            }

            btn.disabled = true;
            btn.textContent = 'Creating account...';

            try {
                const res = await fetch(CTX + '/api/auth/register.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json;charset=UTF-8' },
                    body: JSON.stringify({ email, username, password })
                });

                const data = await res.json();
                if (!res.ok || !data.success) {
                    throw new Error(data.error || 'Failed to create account');
                }

                showAlert('Account created successfully! Welcome, @' + username + '!', false);
                setTimeout(() => {
                    window.location.href = REDIRECT;
                }, 500);
            } catch (err) {
                showAlert(err.message, true);
                btn.disabled = false;
                btn.textContent = 'Create Account';
            }
        }
    </script>
</body>
</html>
