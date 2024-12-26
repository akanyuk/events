function UpdateHeaderUnread(cnt) {
    document.querySelectorAll("#head-activity-badge").forEach(badge => {
        switch (cnt) {
            case 0:
                badge.remove();
                break;
            default:
                badge.innerText = cnt > 99 ? '99+' : cnt;
        }
    });
}
