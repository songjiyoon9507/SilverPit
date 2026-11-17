// 뒤로가기 버튼: 같은 사이트에서 왔으면 이전 페이지로, 아니면 홈으로
document.querySelectorAll("[data-back]").forEach(btn => {
    btn.addEventListener("click", e => {
        if (document.referrer && new URL(document.referrer).origin === location.origin && history.length > 1) {
            e.preventDefault();
            history.back();
        }
    });
});

// 메인 페이지 섹션 바로가기: 현재 보고 있는 섹션 표시
const sectionNav = document.querySelector(".section-nav");

if (sectionNav) {
    const items = [...sectionNav.querySelectorAll(".section-nav-item")];
    const sections = items
        .map(item => document.querySelector(item.getAttribute("href")))
        .filter(Boolean);

    const setActive = id => {
        items.forEach(item => {
            const on = item.getAttribute("href") === "#" + id;
            item.classList.toggle("is-active", on);
            // 활성 탭이 가로 스크롤 영역 밖이면 보이도록 이동
            if (on) {
                const left = item.offsetLeft - (sectionNav.clientWidth - item.clientWidth) / 2;
                sectionNav.scrollTo({ left, behavior: "smooth" });
            }
        });
    };

    const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            if (entry.isIntersecting) setActive(entry.target.id);
        });
    }, { rootMargin: "-120px 0px -60% 0px" });

    sections.forEach(section => observer.observe(section));
}
