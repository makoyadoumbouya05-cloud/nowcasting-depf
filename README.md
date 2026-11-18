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
| 2b | Commerce extérieur : importations et exportations par groupement d'utilisation | Terminée et vérifiée |
| 2c | Indicateurs mensuels par secteur (DEPF, ANRT) : script 04 | Terminée avec les données reçues ; séries à compléter |
| 2d | Demande extérieure (zone Euro) | À faire |
| 3 | Modélisation et évaluation hors échantillon | À faire |
| 4 | Application R Shiny | À faire |

## Structure du dépôt

```
R/
  01_cibles.R    Téléchargement de la VA et calcul du glissement annuel
  02_ipi.R       Chargement des indices de production et calcul du glissement annuel
  03_commerce_exterieur.R   Chargement du commerce extérieur et calcul du glissement annuel
  04_indicateurs_depf.R     Indicateurs DEPF et ANRT : glissement annuel trimestriel
```

## Utilisation

1. Installer R et le package "readxl".
2. Lancer "R/01_cibles.R" : il produit l'objet "cibles"
   (15 secteurs x trimestres, en %).
3. Dans "R/02_ipi.R", adapter la ligne "chemin_ipi" vers le fichier Excel
   des indices de production, puis lancer le script. Il vérifie lui-même
   l'ordre chronologique et la cohérence des données.
4. Dans "R/03_commerce_exterieur.R", adapter la ligne "chemin_ce" vers le fichier
   Excel (feuilles 7 et 8), puis lancer le script. Il produit "imp_gl2" (9 x 48)
   et "exp_gl2" (8 x 48), en %, de T1-2014 à T4-2025. Il vérifie lui-même
   l'ordre chronologique et la cohérence des données.
5. Dans "R/04_indicateurs_depf.R", adapter les lignes "chemin_req" et
   "chemin_anrt" vers les fichiers Excel, puis lancer le script. Il produit
   la liste "indicateurs_gl" (8 séries trimestrielles, en %). Les séries
   s'arrêtent à des dates différentes ; elles seront complétées à l'arrivée
   des données manquantes.
   
## Données
- VA sectorielle : Haut-Commissariat au Plan (HCP), portail data.gov.ma,
  jeu de données "data_i4279". Téléchargée automatiquement par le script.
- Indices de production industrielle : Haut-Commissariat au Plan (HCP),
  enquête de la production industrielle. Le fichier est stocké dans le dépôt.
- Commerce extérieur : importations et exportations mensuelles par groupement
  d'utilisation, 2014M1 à 2025M12. Le fichier n'est pas stocké dans le dépôt.
  Séries écartées : « OR INDUSTRIEL » (trop de mois manquants, import et export)
  et « PRODUITS FINIS D'EQUIPEMENT AGRICOLE » (export, série nulle).
  Les données de 2026 ne sont pas encore intégrées.
- Indicateurs sectoriels : ciment, énergie nette appelée, recettes
  touristiques, pêche, crédits bancaires, dépenses de personnel de l'État
  (DEPF) ; parc Internet (ANRT). Les fichiers ne sont pas stockés dans le dépôt.
  Séries écartées : nuitées et trafic de voix mobile.
- Aucune donnée n'est stockée dans le dépôt.

## Méthode (résumé)

Glissement annuel = 100 x (valeur du trimestre / valeur du même trimestre un an avant - 1).
Pour la VA, les taux obtenus ont été comparés aux taux publiés par le HCP pour
les 2e trimestres 2025 et 2026 : ils coïncident (écarts de 0,1 point au plus).
