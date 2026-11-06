# ==============================================================
# Projet  : Nowcasting sectoriel du PIB non agricole
# Script  : 02_ipi.R
# Objet   : Charger les indices de production (extraction, électricité,
#           industrie hors raffinage) et calculer leur glissement annuel
# Prérequis : avoir exécuté 01_cibles.R (objet `cibles`)
# ==============================================================

library(readxl)
stopifnot(exists("cibles"))

# --- 1. Fichier source (à adapter sur chaque ordinateur) ----------
chemin_ipi <- "chemin/vers/Projet DEPF.xlsx" # à adapter sur chaque ordinateur

# --- 2. Lecture de la feuille « Indice de la production par secteur » (feuille 5)
# col_names = FALSE : aucun en-tête supposé ; col_types = "text" : rien n'est modifié
ipi_brut <- read_excel(chemin_ipi, sheet = 5, col_names = FALSE, col_types = "text")

# --- 3. Repérage des séries et des trimestres ---------------------
# Ligne 1 : noms des séries ; colonne 1 : trimestres (format 2026T2),
# avec en-tête « Trimestres » et note de source à écarter
series_ipi   <- unlist(ipi_brut[1, -1], use.names = FALSE)
lignes_trim  <- grepl("^[0-9]{4}T[1-4]$", ipi_brut[[1]])
periodes_ipi <- ipi_brut[[1]][lignes_trim]

# --- 4. Conversion en nombres et étiquettes -----------------------
bloc_ipi <- ipi_brut[lignes_trim, 2:4]
ipi_num  <- sapply(bloc_ipi, as.numeric)
rownames(ipi_num) <- periodes_ipi
colnames(ipi_num) <- series_ipi

# --- 5. Ordre chronologique (du plus ancien au plus récent) -------
ipi_num <- ipi_num[rev(seq_len(nrow(ipi_num))), ]

# --- 6. Glissement annuel (%) -------------------------------------
# 100 x (indice du trimestre / indice du même trimestre un an avant - 1)
n_ipi <- nrow(ipi_num)
ipi_gliss <- matrix(NA_real_, nrow = n_ipi, ncol = ncol(ipi_num),
                    dimnames = dimnames(ipi_num))
ipi_gliss[5:n_ipi, ] <- 100 * (ipi_num[5:n_ipi, ] / ipi_num[1:(n_ipi - 4), ] - 1)

# --- 7. Noms de trimestres au même format que `cibles` (T2-2026) --
trim_ipi <- rownames(ipi_gliss)
rownames(ipi_gliss) <- paste0("T", substr(trim_ipi, 6, 6), "-", substr(trim_ipi, 1, 4))

# --- 8. Trimestres communs avec `cibles` --------------------------
trim_commun <- intersect(colnames(cibles), rownames(ipi_gliss))

# --- 9. Contrôles -------------------------------------------------
stopifnot(
  ncol(ipi_num) == 3,
  nrow(ipi_num) >= 42,
  sum(is.na(ipi_num)) == 0,
  all(colnames(ipi_num) == series_ipi),
  rownames(ipi_gliss)[1] == "T1-2016",
  "T2-2026" %in% rownames(ipi_gliss),
  length(trim_commun) >= 42,
  sum(!is.na(ipi_gliss[trim_commun, 1])) >= 38,
  abs(ipi_gliss["T2-2026", "Industries Extractives"] - (-28.8)) < 0.05
)

cat("Script 02 terminé :", nrow(ipi_gliss), "trimestres,",
    ncol(ipi_gliss), "séries,", length(trim_commun), "trimestres communs avec cibles\n")
