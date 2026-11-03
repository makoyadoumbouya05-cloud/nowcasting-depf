# ==============================================================
# Projet  : Nowcasting sectoriel du PIB non agricole (DEPF)
# Script  : 01_cibles.R
# Objet   : Construire le glissement annuel de la VA des 15 secteurs cibles
# Source  : HCP, via data.gov.ma (jeu data_i4279)
#           VA cvs, volume chaîné aux prix de l'année précédente, base 2014
# ==============================================================

library(readxl)

# --- 1. Téléchargement ------------------------------------------
url_va     <- "https://data.gov.ma/data/dataset/6f875017-2373-419b-9a85-2eed7cbe0d2e/resource/7f660503-5515-4c92-b11b-53234f24d32d/download/i_i4279_data.xlsx"
fichier_va <- "va_chainee_base2014.xlsx"
download.file(url_va, destfile = fichier_va, mode = "wb")
va_brut <- read_excel(fichier_va, col_names = FALSE, col_types = "text")

# --- 2. Repérage des trimestres et des branches ------------------
periodes <- unlist(va_brut[2, -1], use.names = FALSE)    # ligne 2 : T2-2026, T1-2026...
branches <- va_brut[[1]][3:nrow(va_brut)]                # colonne 1 : noms des branches

# --- 3. Conversion du texte en nombres ---------------------------
bloc   <- va_brut[3:nrow(va_brut), -1]                   # uniquement les chiffres
va_num <- sapply(bloc, as.numeric)
rownames(va_num) <- branches
colnames(va_num) <- periodes

# --- 4. Ordre chronologique et dates -----------------------------
va_num       <- va_num[, rev(seq_len(ncol(va_num)))]     # du plus ancien au plus récent
periodes_ord <- colnames(va_num)
annee <- as.integer(substr(periodes_ord, 4, 7))
trim  <- as.integer(substr(periodes_ord, 2, 2))
dates <- as.Date(paste0(annee, "-", (trim - 1) * 3 + 1, "-01"))

# --- 5. Glissement annuel (%) ------------------------------------
# 100 x (valeur du trimestre / valeur du même trimestre un an avant - 1)
n     <- ncol(va_num)
gliss <- matrix(NA_real_, nrow = nrow(va_num), ncol = n, dimnames = dimnames(va_num))
gliss[, 5:n] <- 100 * (va_num[, 5:n] / va_num[, 1:(n - 4)] - 1)

# --- 6. Les 15 secteurs cibles (hors agriculture, sous-branches, sous-totaux)
cibles <- gliss[c(2:4, 18:29), ]
stopifnot(rownames(cibles)[1] == "Pêche",                # la sélection par numéro de ligne
          rownames(cibles)[5] == "Construction")         # est-elle toujours la bonne ?

rownames(cibles) <- c("peche", "extraction", "transformation", "electricite_eau",
                      "construction", "commerce", "transport", "hebergement",
                      "info_comm", "finance", "immobilier", "services_entreprises",
                      "administration", "educ_sante", "autres_services")

# --- 7. Contrôles ------------------------------------------------
stopifnot(nrow(va_num) == 32,
          ncol(va_num) >= 50,
          sum(is.na(va_num)) == 0,
          all(diff(dates) > 0),
          nrow(cibles) == 15,
          round(cibles["construction", "T2-2026"], 1) == 2.8)

cat("Script 01 terminé : cibles =", nrow(cibles), "secteurs x", ncol(cibles), "trimestres\n")
