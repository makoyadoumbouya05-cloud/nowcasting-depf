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
| 2a | Indices de production industrielle (extraction, électricité, industrie hors raffinage) | Terminée et vérifiée |
| 2b | Autres indicateurs mensuels par secteur | En attente de données |
| 3 | Modélisation et évaluation hors échantillon | À faire |
| 4 | Application R Shiny | À faire |

## Structure du dépôt

```
R/
  01_cibles.R    Téléchargement de la VA et calcul du glissement annuel
  02_ipi.R       Chargement des indices de production et calcul du glissement annuel
```

## Utilisation

1. Installer R et le package `readxl`.
2. Lancer `R/01_cibles.R` : il produit l'objet `cibles`
   (15 secteurs x trimestres, en %).
3. Dans `R/02_ipi.R`, adapter la ligne `chemin_ipi` vers le fichier Excel
   des indices de production, puis lancer le script. Il vérifie lui-même
   l'ordre chronologique et la cohérence des données.

## Données

- VA sectorielle : Haut-Commissariat au Plan (HCP), portail data.gov.ma,
  jeu de données `data_i4279`. Téléchargée automatiquement par le script.
- Indices de production industrielle : Haut-Commissariat au Plan (HCP),
  enquête de la production industrielle. Le fichier n'est pas stocké dans le dépôt.
- Aucune donnée n'est stockée dans le dépôt.

## Méthode (résumé)

Glissement annuel = 100 x (valeur du trimestre / valeur du même trimestre un an avant - 1).
Pour la VA, les taux obtenus ont été comparés aux taux publiés par le HCP pour
les 2e trimestres 2025 et 2026 : ils coïncident (écarts de 0,1 point au plus).
