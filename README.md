# Nowcasting sectoriel du PIB non agricole du Maroc

Projet de nowcasting de la valeur ajoutée (VA) par secteur d'activité du Maroc,
inspiré du modèle GDPNow de la Fed d'Atlanta, mais selon l'approche **par l'offre** :
on prévoit la VA de chaque secteur non agricole, puis on l'agrège.

Projet réalisé dans le cadre d'un stage. Travail en cours.

## Objectif

- Cible : glissement annuel de la VA de chaque secteur non agricole
  (volume chaîné, base 2014, données corrigées des variations saisonnières).
- Horizon : trimestre en cours et trimestre suivant.
- Livrables prévus : modèle, application R Shiny interactive, article.

## État d'avancement

| Étape | Contenu | État |
|---|---|---|
| 1 | Cibles : glissement annuel de la VA des 15 secteurs | Terminée et vérifiée |
| 2 | Collecte des indicateurs mensuels par secteur | À faire |
| 3 | Modélisation et évaluation hors échantillon | À faire |
| 4 | Application R Shiny | À faire |

## Structure du dépôt

```
R/
  01_cibles.R    Téléchargement de la VA et calcul du glissement annuel
```

## Utilisation

1. Installer R et le package `readxl`.
2. Lancer `R/01_cibles.R`. Le script télécharge la série et produit
   l'objet `cibles` (15 secteurs x trimestres, en %).

## Données

- Source : Haut-Commissariat au Plan (HCP), portail data.gov.ma,
  jeu de données `data_i4279`.
- Les données ne sont pas stockées dans le dépôt : le script les télécharge.

## Méthode (résumé)

Glissement annuel = 100 x (VA du trimestre / VA du même trimestre un an avant - 1).
Les valeurs obtenues ont été comparées aux taux publiés par le HCP pour
les 2e trimestres 2025 et 2026 ; elles coïncident (écarts de 0,1 point au plus).
