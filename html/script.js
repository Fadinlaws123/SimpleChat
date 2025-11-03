const feed = document.getElementById('chat-feed');
const inputBox = document.getElementById('chat-input-container');
const input = document.getElementById('chat-input');
const container = document.getElementById('chat-container');
const suggWrap = document.getElementById('suggestions');

let suggestions = [];
let filtered = [];
let activeIdx = 0;

let history = [];
let messageHistory = [];
let historyIndex = -1;

let hideTimer = null;
const autoHideDelay = 5000; // 5 seconds — adjust to your liking

/* ========= HELPERS ========= */
function escapeHTML(str) {
    if (typeof str !== 'string') return '';
    return str.replace(/[&<>"']/g, m => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    }[m]));
}

/* ========= SHOW / HIDE ========= */
function showChat() {
    container.classList.add('visible');
    container.classList.remove('faded');

    resetHideTimer();
}

function hideChat() {
    container.classList.add('faded');
}

function resetHideTimer() {
    if (hideTimer) clearTimeout(hideTimer);
    hideTimer = setTimeout(() => {
        if (document.activeElement !== input) hideChat();
    }, autoHideDelay);
}

/* ========= MESSAGE HANDLING ========= */
function addMessage(data) {
    if (!data) return;

    const el = document.createElement('div');
    el.classList.add('message');

    const color = data.color || [255, 255, 255];
    const nm = escapeHTML(data.args?.[0] || '');
    const tx = escapeHTML(data.args?.[1] || '');
    el.innerHTML = `<span class="sender" style="color:rgb(${color.join(',')})">${nm}:</span> ${tx}`;
    feed.appendChild(el);
    feed.scrollTop = feed.scrollHeight;
    showChat();
}

function addSimpleChatMessage(payload) {
    if (!payload || !payload.name) return;
    const el = document.createElement('div');
    el.classList.add('message');
    el.dataset.type = payload.kind || 'ooc';

    let icon = 'fa-regular fa-comments';
    if (payload.kind === 'me') icon = 'fa-solid fa-user-astronaut';
    else if (payload.kind === 'do') icon = 'fa-solid fa-comment-dots';
    else if (payload.kind === 'gme') icon = 'fa-solid fa-bolt';

    el.innerHTML = `<i class="${icon}"></i><span class="sender">${escapeHTML(payload.name)}:</span> ${escapeHTML(payload.text)}`;
    feed.appendChild(el);
    feed.scrollTop = feed.scrollHeight;
    showChat();
}

/* ========= SUGGESTIONS ========= */
function renderSuggestions() {
    suggWrap.style.top = `${inputBox.offsetTop + inputBox.offsetHeight - 2}px`;
    suggWrap.style.width = `${container.clientWidth - 80}px`;
    if (filtered.length === 0) {
        suggWrap.classList.add('hidden');
        return;
    }

    suggWrap.innerHTML = filtered.map((s, i) => `
        <div class="sug ${i === activeIdx ? 'active' : ''}">
            <div><b>${escapeHTML(s.name)}</b> ${s.params?.map(p => `[${escapeHTML(p.name)}]`).join(' ') || ''}</div>
            <div style="opacity:.7">${escapeHTML(s.help || '')}</div>
        </div>
    `).join('');

    suggWrap.classList.remove('hidden');
}

function filterSuggestions(text) {
    if (!text.startsWith('/')) {
        suggWrap.classList.add('hidden');
        return;
    }
    const key = text.split(' ')[0].toLowerCase();
    filtered = suggestions.filter(s => s.name.toLowerCase().startsWith(key));
    activeIdx = 0;
    renderSuggestions();
}

/* ========= MESSAGE EVENTS ========= */
window.addEventListener('message', (e) => {
    const d = e.data;
    if (!d || !d.type) return;

    switch (d.type) {
        case 'chat:addMessage': {
            const feed = document.getElementById('chat-feed');
            const { args = [], color = [255, 255, 255], template, text } = d;

            let messageHtml = '';

            if (template) {
                messageHtml = template;
                args.forEach((arg, i) => {
                    const safeArg = escapeHTML(arg);
                    messageHtml = messageHtml.replace(`{${i}}`, safeArg);
                });
            } else if (args.length > 0) {
                messageHtml = `<b style="color: rgb(${color.join(',')});">${escapeHTML(args[0])}</b> ${escapeHTML(args[1] || '')}`;
            } else if (text) {
                messageHtml = `<span style="color: rgb(${color.join(',')});">${escapeHTML(text)}</span>`;
            } else {
                messageHtml = `<span style="color: rgb(${color.join(',')}); opacity:.7;">Unknown message</span>`;
            }

            const msgElem = document.createElement('div');
            msgElem.className = 'message template';
            msgElem.innerHTML = messageHtml;

            feed.appendChild(msgElem);
            feed.scrollTop = feed.scrollHeight;
            break;
        }
        case 'simplechat:add':
            addSimpleChatMessage(d.data);
            break;
        case 'chat:clear':
            feed.innerHTML = '';
            break;
        case 'chat:addSuggestion':
            suggestions.push({ name: d.name, help: d.help, params: d.params || [] });
            break;
        case 'chat:removeSuggestion':
            suggestions = suggestions.filter(s => s.name !== d.name);
            break;
        case 'chat:open':
            container.classList.add('visible');
            container.classList.remove('faded');
            inputBox.classList.remove('hidden');
            input.focus();
            clearTimeout(hideTimer);
            break;
        case 'chat:close':
            inputBox.classList.add('hidden');
            input.blur();
            suggWrap.classList.add('hidden');
            resetHideTimer();
            break;
        case 'chat:updateBuiltIns': {
            const header = document.getElementById('chat-header');
            if (!header) return;

            const right = header.querySelector('.right');
            if (!right) return;

            right.innerHTML = '';

            const builtIns = d.builtIns || {};
            const orderedCommands = d.commandOrder || ['me', 'do', 'gme', 'ooc'];

            const icons = {
                me: '<i class="fa-solid fa-user-astronaut"></i>',
                'do': '<i class="fa-solid fa-comment-dots"></i>',
                gme: '<i class="fa-solid fa-bolt"></i>',
                ooc: '<i class="fa-regular fa-comments"></i>'
            };

            for (const key of orderedCommands) {
                if (!builtIns[key]) continue;
                const tag = document.createElement('span');
                tag.className = `tag ${key}`;
                tag.innerHTML = `${icons[key] || ''} /${key}`;
                right.appendChild(tag);
            }
            break;
        }
        case 'simplechat:addTemplate': {
            const { icon, title, message, color } = d.data;

            const row = document.createElement('div');
            row.className = 'sc-row';

            row.innerHTML = `
      <div class="sc-card" style="--bar-r:${color[0]}; --bar-g:${color[1]}; --bar-b:${color[2]};">
        <div class="sc-card-head">
          <span class="sc-icon">${icon || '💬'}</span>
          <span class="sc-title">${escapeHTML(title || 'SimpleChat')}</span>
        </div>
        <div class="sc-card-body">${escapeHTML(message || '')}</div>
      </div>
    `;

            feed.appendChild(row);
            feed.scrollTop = feed.scrollHeight;
            showChat();
            break;
        }
        case 'simplechat:addInline': {
            const { name, icon, text, color } = d.data;

            const el = document.createElement('div');
            el.classList.add('message', 'custom-inline');
            el.innerHTML = `
        <i class="inline-icon">${icon || '💬'}</i>
        <span class="sender" style="color: rgb(${color.join(',')});">${escapeHTML(name)}:</span>
        ${escapeHTML(text)}
    `;

            feed.appendChild(el);
            feed.scrollTop = feed.scrollHeight;
            showChat();
            break;
        }
    }
});

/* ========= INPUT ========= */
input.addEventListener('input', () => filterSuggestions(input.value));

input.addEventListener('keydown', (e) => {
    const key = e.key;

    if (key === 'Enter') {
        e.preventDefault();
        const message = input.value.trim();

        if (message === '') {
            fetch(`https://${GetParentResourceName()}/chat:escape`, { method: 'POST', body: '{}' });
            input.value = '';
            suggWrap.classList.add('hidden');
            return;
        }

        if (message !== history[history.length - 1]) {
            history.push(message);
        }
        historyIndex = -1;

        submitMessage();
        input.value = '';
        suggWrap.classList.add('hidden');
        return;
    }

    if (key === 'ArrowUp') {
        e.preventDefault();
        if (history.length > 0) {
            if (historyIndex === -1) historyIndex = history.length - 1;
            else if (historyIndex > 0) historyIndex--;
            input.value = history[historyIndex] || '';
            input.setSelectionRange(input.value.length, input.value.length);
        }
        return;
    }

    if (key === 'ArrowDown') {
        e.preventDefault();
        if (history.length > 0) {
            if (historyIndex < history.length - 1) historyIndex++;
            else historyIndex = -1;
            input.value = historyIndex === -1 ? '' : history[historyIndex];
            input.setSelectionRange(input.value.length, input.value.length);
        }
        return;
    }

    if (key === 'Escape') {
        e.preventDefault();
        fetch(`https://${GetParentResourceName()}/chat:escape`, { method: 'POST', body: '{}' });
        input.value = '';
        suggWrap.classList.add('hidden');
        return;
    }
});

suggWrap.addEventListener('click', (e) => {
    const item = e.target.closest('.sug');
    if (!item) return;
    const idx = Array.from(suggWrap.children).indexOf(item);
    if (idx >= 0) {
        input.value = filtered[idx].name + ' ';
        filterSuggestions(input.value);
        input.focus();
    }
});

/* ========= SEND ========= */
function submitMessage() {
    const message = input.value.trim();
    if (message === '') return;

    messageHistory.push(message);
    if (messageHistory.length > 100) messageHistory.shift();
    historyIndex = -1;

    fetch(`https://${GetParentResourceName()}/chat:submit`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message })
    }).then(() => {
        input.value = '';
        suggWrap.classList.add('hidden');
    }).catch(err => console.error('Chat submit error:', err));

    resetHideTimer();
}

document.addEventListener('mousedown', (e) => {
    if (!container.contains(e.target)) {
        fetch(`https://${GetParentResourceName()}/chat:escape`, { method: 'POST', body: '{}' });
        suggWrap.classList.add('hidden');
        input.value = '';
    }
});
