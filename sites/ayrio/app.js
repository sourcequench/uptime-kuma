// Subtle entrance animations for ayrio.net
document.addEventListener('DOMContentLoaded', () => {
    const cards = document.querySelectorAll('.card');
    const hero = document.querySelector('.hero');

    // Initial state
    hero.style.opacity = '0';
    hero.style.transform = 'translateY(10px)';
    hero.style.transition = 'opacity 0.8s ease, transform 0.8s ease';

    cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(10px)';
        card.style.transition = `opacity 0.6s ease ${0.2 + (index * 0.1)}s, transform 0.6s ease ${0.2 + (index * 0.1)}s`;
    });

    // Trigger animations
    setTimeout(() => {
        hero.style.opacity = '1';
        hero.style.transform = 'translateY(0)';
        
        cards.forEach(card => {
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        });
    }, 100);
});
