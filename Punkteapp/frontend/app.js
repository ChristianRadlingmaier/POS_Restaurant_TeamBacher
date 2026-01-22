// Configuration
const API_URL = 'http://localhost:8080/api';
let currentUser = {
    email: localStorage.getItem('userEmail') || null,
    password: localStorage.getItem('userPassword') || null,
    isAdmin: localStorage.getItem('userRole') === 'ADMIN'
};

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    if (currentUser.email && currentUser.password) {
        loadUserData();
        showPage('dashboard');
        updateNavbar();
    } else {
        showPage('auth');
    }
});

// Page Navigation
function showPage(pageName) {
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    const page = document.getElementById(pageName + 'Page');
    if (page) {
        page.classList.add('active');
        
        // Load data for specific pages
        if (pageName === 'dashboard') {
            loadDashboard();
        } else if (pageName === 'rewards') {
            loadRewardsPage();
        } else if (pageName === 'admin') {
            loadAdminPanel();
        }
    }
}

function updateNavbar() {
    const dashboardLink = document.getElementById('dashboardLink');
    const adminLink = document.getElementById('adminLink');
    const logoutBtn = document.getElementById('logoutBtn');
    
    if (currentUser.email) {
        dashboardLink.style.display = 'inline';
        logoutBtn.style.display = 'inline';
        if (currentUser.isAdmin) {
            adminLink.style.display = 'inline';
        }
    } else {
        dashboardLink.style.display = 'none';
        adminLink.style.display = 'none';
        logoutBtn.style.display = 'none';
    }
}

// Authentication
function switchAuthForm() {
    const loginForm = document.getElementById('loginForm').parentElement;
    const registerBox = document.getElementById('registerBox');
    loginForm.style.display = loginForm.style.display === 'none' ? 'block' : 'none';
    registerBox.style.display = registerBox.style.display === 'none' ? 'block' : 'none';
}

async function login(event) {
    event.preventDefault();
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;

    try {
        const response = await fetch(`${API_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password }),
            mode: 'cors'
        });

        let data;
        try {
            data = await response.json();
        } catch (e) {
            showToast('❌ Ungültige Response vom Server', 'error');
            return;
        }
        
        if (response.ok && data.token) {
            currentUser.email = email;
            currentUser.password = password;
            localStorage.setItem('userEmail', email);
            localStorage.setItem('userPassword', password);
            localStorage.setItem('token', data.token);
            
            // Get user role
            await loadUserData();
            
            updateNavbar();
            showPage('dashboard');
            showToast('Erfolgreich angemeldet!', 'success');
            document.getElementById('loginForm').reset();
        } else {
            showToast(data.error || data.message || 'Login fehlgeschlagen', 'error');
        }
    } catch (error) {
        console.error('Login error:', error);
        showToast('❌ Fehler: Backend nicht erreichbar? Läuft der Server auf http://localhost:8080? ' + error.message, 'error');
    }
}

async function register(event) {
    event.preventDefault();
    const firstname = document.getElementById('registerFirstname').value;
    const lastname = document.getElementById('registerLastname').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;

    try {
        const response = await fetch(`${API_URL}/auth/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ firstname, lastname, email, password }),
            mode: 'cors'
        });

        let data;
        try {
            data = await response.json();
        } catch (e) {
            showToast('❌ Ungültige Response vom Server', 'error');
            return;
        }
        
        if (response.ok && data.token) {
            showToast('Registrierung erfolgreich! Bitte melden Sie sich an.', 'success');
            document.getElementById('registerForm').reset();
            switchAuthForm();
            document.getElementById('loginEmail').value = email;
        } else {
            showToast(data.error || data.message || 'Registrierung fehlgeschlagen', 'error');
        }
    } catch (error) {
        console.error('Register error:', error);
        showToast('❌ Fehler: Backend nicht erreichbar? Läuft der Server auf http://localhost:8080? ' + error.message, 'error');
    }
}

function logout() {
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userPassword');
    localStorage.removeItem('token');
    localStorage.removeItem('userRole');
    currentUser = { email: null, password: null, isAdmin: false };
    updateNavbar();
    showPage('auth');
    showToast('Abgemeldet', 'success');
}

// User Data
async function loadUserData() {
    if (!currentUser.email || !currentUser.password) return;

    try {
        const response = await fetch(
            `${API_URL}/user/me?email=${encodeURIComponent(currentUser.email)}&password=${encodeURIComponent(currentUser.password)}`
        );
        const user = await response.json();
        
        if (response.ok) {
            localStorage.setItem('userRole', user.role);
            currentUser.isAdmin = user.role === 'ADMIN';
            updateNavbar();
            return user;
        }
    } catch (error) {
        console.error('Error loading user data:', error);
    }
}

// Dashboard
async function loadDashboard() {
    const user = await loadUserData();
    if (!user) return;

    document.getElementById('userName').textContent = user.firstname + ' ' + user.lastname;
    document.getElementById('userEmail').textContent = user.email;
    document.getElementById('userPoints').textContent = user.points;
    document.getElementById('userRole').textContent = user.role === 'ADMIN' ? 'Administrator' : 'Benutzer';

    // Load profile form data
    document.getElementById('profileFirstname').value = user.firstname;
    document.getElementById('profileLastname').value = user.lastname;
    document.getElementById('profileEmail').value = user.email;

    loadRewards();
    loadHistory();
}

// Rewards
async function loadRewards() {
    try {
        console.log('Loading rewards from:', `${API_URL}/user/rewards`);
        const response = await fetch(`${API_URL}/user/rewards`, {
            mode: 'cors'
        });
        
        console.log('Rewards response status:', response.status);
        const rewards = await response.json();
        console.log('Rewards data:', rewards);
        
        if (response.ok) {
            const container = document.getElementById('rewardsContainer');
            container.innerHTML = '';
            
            if (!rewards || rewards.length === 0) {
                container.innerHTML = '<p class="text-muted">❌ Keine Rewards in der Datenbank gefunden. Bitte erstelle einige im Admin Panel!</p>';
                return;
            }
            
            rewards.forEach(reward => {
                const card = createRewardCard(reward, true);
                container.appendChild(card);
            });
        } else {
            const container = document.getElementById('rewardsContainer');
            container.innerHTML = `<p class="text-muted">❌ Fehler beim Laden der Rewards (HTTP ${response.status})</p>`;
        }
    } catch (error) {
        console.error('Error loading rewards:', error);
        const container = document.getElementById('rewardsContainer');
        container.innerHTML = `<p class="text-muted">❌ Fehler: ${error.message}</p>`;
        showToast('Fehler beim Laden der Rewards: ' + error.message, 'error');
    }
}

async function loadRewardsPage() {
    try {
        console.log('Loading rewards page...');
        const response = await fetch(`${API_URL}/user/rewards`, {
            mode: 'cors'
        });
        const rewards = await response.json();
        console.log('Rewards page data:', rewards);
        
        if (response.ok) {
            const container = document.getElementById('rewardsDetailContainer');
            container.innerHTML = '';
            
            if (!rewards || rewards.length === 0) {
                container.innerHTML = '<p class="text-muted">❌ Keine Rewards verfügbar</p>';
                return;
            }
            
            rewards.forEach(reward => {
                const card = createRewardCard(reward, true);
                container.appendChild(card);
            });
        } else {
            document.getElementById('rewardsDetailContainer').innerHTML = `<p class="text-muted">❌ Fehler beim Laden der Rewards</p>`;
        }
    } catch (error) {
        console.error('Error loading rewards page:', error);
        document.getElementById('rewardsDetailContainer').innerHTML = `<p class="text-muted">❌ Fehler: ${error.message}</p>`;
    }
}

function createRewardCard(reward, clickable = false) {
    const card = document.createElement('div');
    card.className = 'reward-card';
    const isAvailable = reward.status === true || reward.status === 'AVAILABLE';
    const statusClass = isAvailable ? 'available' : 'unavailable';
    const statusText = isAvailable ? 'Verfügbar' : 'Nicht verfügbar';
    
    card.innerHTML = `
        <h4>${reward.title}</h4>
        <p>${reward.description}</p>
        <div class="reward-cost">${reward.pointsCost} Punkte</div>
        <div class="reward-status ${statusClass}">${statusText}</div>
        ${isAvailable ? `<button onclick="redeemReward(${reward.rewardId})" class="btn btn-primary" style="margin-top: 1rem;">Einlösen</button>` : ''}
    `;
    
    return card;
}

async function redeemReward(rewardId) {
    if (!currentUser.email || !currentUser.password) return;
    
    try {
        const response = await fetch(`${API_URL}/user/redeem?email=${encodeURIComponent(currentUser.email)}&password=${encodeURIComponent(currentUser.password)}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ rewardId })
        });

        const data = await response.json();
        
        if (response.ok) {
            showToast('Reward erfolgreich eingelöst!', 'success');
            loadDashboard();
        } else {
            showToast(data.message || 'Fehler beim Einlösen des Rewards', 'error');
        }
    } catch (error) {
        console.error('Error redeeming reward:', error);
        showToast('Fehler: ' + error.message, 'error');
    }
}

// History
async function loadHistory() {
    if (!currentUser.email || !currentUser.password) return;

    try {
        const response = await fetch(
            `${API_URL}/user/history?email=${encodeURIComponent(currentUser.email)}&password=${encodeURIComponent(currentUser.password)}`
        );
        const history = await response.json();
        
        if (response.ok) {
            const container = document.getElementById('historyContainer');
            container.innerHTML = '';
            
            if (history.length === 0) {
                container.innerHTML = '<p class="text-muted">Keine Transaktionen vorhanden</p>';
                return;
            }
            
            history.forEach(item => {
                const div = document.createElement('div');
                div.className = 'history-item';
                const date = new Date(item.date).toLocaleDateString('de-DE', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                });
                
                div.innerHTML = `
                    <p><strong>${item.type === 'INVOICE' ? '💰 Punkte erhalten' : '🎁 Reward eingelöst'}</strong></p>
                    <p>${item.description}</p>
                    <p class="date">${date}</p>
                `;
                container.appendChild(div);
            });
        }
    } catch (error) {
        console.error('Error loading history:', error);
    }
}

// Profile
async function updateProfile(event) {
    event.preventDefault();
    
    if (!currentUser.email || !currentUser.password) return;

    const firstname = document.getElementById('profileFirstname').value || null;
    const lastname = document.getElementById('profileLastname').value || null;
    const email = document.getElementById('profileEmail').value || null;
    const password = document.getElementById('profilePassword').value || null;

    try {
        const response = await fetch(
            `${API_URL}/user/profile?email=${encodeURIComponent(currentUser.email)}&password=${encodeURIComponent(currentUser.password)}`,
            {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ firstname, lastname, email, password })
            }
        );

        if (response.ok) {
            // Update stored credentials if email changed
            if (email) {
                currentUser.email = email;
                localStorage.setItem('userEmail', email);
            }
            
            showToast('Profil erfolgreich aktualisiert!', 'success');
            loadDashboard();
            showPage('dashboard');
        } else {
            const data = await response.json();
            showToast(data.message || 'Fehler beim Aktualisieren des Profils', 'error');
        }
    } catch (error) {
        console.error('Error updating profile:', error);
        showToast('Fehler: ' + error.message, 'error');
    }
}

// Points & Invoices
async function addInvoice() {
    if (!currentUser.email || !currentUser.password) return;

    const pointsEarned = prompt('Wie viele Punkte möchten Sie hinzufügen?', '10');
    if (!pointsEarned || isNaN(pointsEarned)) return;

    try {
        const response = await fetch(
            `${API_URL}/user/invoices?email=${encodeURIComponent(currentUser.email)}&password=${encodeURIComponent(currentUser.password)}`,
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ pointsEarned: parseInt(pointsEarned) })
            }
        );

        const data = await response.json();
        
        if (response.ok) {
            showToast(`${pointsEarned} Punkte hinzugefügt!`, 'success');
            loadDashboard();
        } else {
            showToast(data.message || 'Fehler beim Hinzufügen der Punkte', 'error');
        }
    } catch (error) {
        console.error('Error adding invoice:', error);
        showToast('Fehler: ' + error.message, 'error');
    }
}

// Admin Panel
async function loadAdminPanel() {
    if (!currentUser.isAdmin) {
        showToast('Nur Administratoren können auf diesen Bereich zugreifen', 'error');
        showPage('dashboard');
        return;
    }

    loadAdminUsers();
    loadAdminRewards();
}

async function loadAdminUsers() {
    try {
        const response = await fetch(`${API_URL}/admin/users`);
        const users = await response.json();
        
        if (response.ok) {
            const container = document.getElementById('usersContainer');
            container.innerHTML = '';
            
            users.forEach(user => {
                const div = document.createElement('div');
                div.className = 'user-item';
                
                div.innerHTML = `
                    <div class="user-item-info">
                        <p><strong>${user.name}</strong></p>
                        <p>${user.email}</p>
                        <p>Punkte: <strong>${user.points}</strong> | Rolle: <strong>${user.role}</strong></p>
                    </div>
                    <div class="user-item-actions">
                        <input type="number" id="points-${user.userId}" value="${user.points}" placeholder="Punkte">
                        <button onclick="updateUserPoints(${user.userId})" class="btn btn-secondary">Aktualisieren</button>
                    </div>
                `;
                container.appendChild(div);
            });
        }
    } catch (error) {
        console.error('Error loading users:', error);
        showToast('Fehler beim Laden der Benutzer: ' + error.message, 'error');
    }
}

async function updateUserPoints(userId) {
    const input = document.getElementById(`points-${userId}`);
    const points = parseInt(input.value);
    
    if (isNaN(points)) {
        showToast('Bitte geben Sie eine gültige Punktzahl ein', 'warning');
        return;
    }

    try {
        const response = await fetch(`${API_URL}/admin/users/${userId}/points?points=${points}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' }
        });

        if (response.ok) {
            showToast('Punkte aktualisiert!', 'success');
            loadAdminUsers();
        } else {
            showToast('Fehler beim Aktualisieren der Punkte', 'error');
        }
    } catch (error) {
        console.error('Error updating points:', error);
        showToast('Fehler: ' + error.message, 'error');
    }
}

async function loadAdminRewards() {
    try {
        console.log('Loading admin rewards...');
        const response = await fetch(`${API_URL}/user/rewards`, {
            mode: 'cors'
        });
        const rewards = await response.json();
        console.log('Admin rewards data:', rewards);
        
        if (response.ok) {
            const container = document.getElementById('adminRewardsContainer');
            container.innerHTML = '';
            
            if (!rewards || rewards.length === 0) {
                container.innerHTML = '<p class="text-muted">❌ Keine Rewards vorhanden</p>';
                return;
            }
            
            rewards.forEach(reward => {
                const div = document.createElement('div');
                div.className = 'reward-item';
                const statusText = reward.status === true ? 'AVAILABLE' : 'UNAVAILABLE';
                
                div.innerHTML = `
                    <h5>${reward.title}</h5>
                    <p>${reward.description}</p>
                    <p>Punkte: <strong>${reward.pointsCost}</strong> | Status: <strong>${statusText}</strong></p>
                    <div class="reward-item-actions">
                        <button onclick="showEditRewardForm(${reward.rewardId}, '${reward.title}', '${reward.description.replace(/'/g, "\\'")}', ${reward.pointsCost}, '${statusText}')" class="btn btn-secondary">Bearbeiten</button>
                        <button onclick="deleteReward(${reward.rewardId})" class="btn btn-danger">Löschen</button>
                    </div>
                `;
                container.appendChild(div);
            });
        } else {
            document.getElementById('adminRewardsContainer').innerHTML = `<p class="text-muted">❌ Fehler beim Laden der Rewards</p>`;
        }
    } catch (error) {
        console.error('Error loading admin rewards:', error);
        document.getElementById('adminRewardsContainer').innerHTML = `<p class="text-muted">❌ Fehler: ${error.message}</p>`;
    }
}

async function createReward(event) {
    event.preventDefault();
    
    const title = document.getElementById('rewardTitle').value;
    const description = document.getElementById('rewardDesc').value;
    const pointsCost = parseInt(document.getElementById('rewardPoints').value);
    const status = document.getElementById('rewardStatus').value;

    try {
        const response = await fetch(`${API_URL}/admin/rewards`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                title,
                description,
                pointsCost,
                status
            })
        });

        if (response.ok) {
            showToast('Reward erstellt!', 'success');
            document.getElementById('rewardForm').reset();
            loadAdminRewards();
        } else {
            showToast('Fehler beim Erstellen des Rewards', 'error');
        }
    } catch (error) {
        console.error('Error creating reward:', error);
        showToast('Fehler: ' + error.message, 'error');
    }
}

function showEditRewardForm(id, title, description, pointsCost, status) {
    const newTitle = prompt('Titel:', title);
    if (newTitle === null) return;

    const newDesc = prompt('Beschreibung:', description);
    if (newDesc === null) return;

    const newPoints = prompt('Punkte:', pointsCost);
    if (newPoints === null) return;

    const newStatus = prompt('Status (AVAILABLE/UNAVAILABLE):', status);
    if (newStatus === null) return;

    updateReward(id, newTitle, newDesc, parseInt(newPoints), newStatus);
}

async function updateReward(id, title, description, pointsCost, status) {
    try {
        const response = await fetch(`${API_URL}/admin/rewards/${id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                title,
                description,
                pointsCost,
                status
            })
        });

        if (response.ok) {
            showToast('Reward aktualisiert!', 'success');
            loadAdminRewards();
        } else {
            showToast('Fehler beim Aktualisieren des Rewards', 'error');
        }
    } catch (error) {
        console.error('Error updating reward:', error);
        showToast('Fehler: ' + error.message, 'error');
    }
}

async function deleteReward(id) {
    if (!confirm('Sind Sie sicher, dass Sie dieses Reward löschen möchten?')) return;

    try {
        const response = await fetch(`${API_URL}/admin/rewards/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            showToast('Reward gelöscht!', 'success');
            loadAdminRewards();
        } else {
            showToast('Fehler beim Löschen des Rewards', 'error');
        }
    } catch (error) {
        console.error('Error deleting reward:', error);
        showToast('Fehler: ' + error.message, 'error');
    }
}

// Toast Notification
function showToast(message, type = 'info') {
    const toast = document.getElementById('toast');
    toast.textContent = message;
    toast.className = `toast show ${type}`;
    
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}
