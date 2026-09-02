# Politique de sécurité

## Versions supportées

Seule la dernière version publiée sur la branche principale reçoit des correctifs de sécurité.

## Signaler une vulnérabilité

Ne créez pas d'issue publique pour une faille de sécurité potentielle.
Contactez directement le mainteneur du projet (email/canal privé à définir par projet dérivé)
en décrivant :

- la nature de la vulnérabilité,
- les étapes de reproduction,
- l'impact potentiel.

Un correctif ou un accusé de réception est visé sous 7 jours.

## Bonnes pratiques appliquées dans ce template

- Aucune donnée sensible ne doit être committée (`.env` est ignoré par `.gitignore`).
- Dependabot (`.github/dependabot.yml`) surveille les dépendances vulnérables.
- Pensez à activer _GitHub Secret Scanning_ et _Code scanning (CodeQL)_ sur le dépôt distant.
