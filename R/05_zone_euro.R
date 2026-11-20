# 05_zone_euro.R
# Demande extérieure : PIB de la zone Euro (Eurostat), glissement annuel en %
# Données publiques, téléchargées à chaque exécution (chiffres révisables).

library(eurostat)

# Fonctions communes (identiques à 04) --------------------------------------
gl <- function(x) {
  n <- length(x)
  c(rep(NA, 4), 100 * (x[5:n] / x[1:(n - 4)] - 1))
}

lab_trim_mois <- function(num) {
  annee <- (num - 1) %/% 12
  mois  <- (num - 1) %% 12 + 1
  paste0("T", (mois - 1) %/% 3 + 1, "-", annee)
}

# 1. Téléchargement ----------------------------------------------------------
# PIB (B1GQ), volumes chaînés 2020, désaisonnalisé et corrigé des jours ouvrables
filtres_pib <- list(freq = "Q", unit = "CLV20_MEUR", s_adj = "SCA",
                    na_item = "B1GQ", geo = "EA20")
pib_ea <- get_eurostat("namq_10_gdp", filters = filtres_pib)

# 2. Suppression des trimestres vides (avant T1-1995) -----------------------
pib_ok <- pib_ea[!is.na(pib_ea$values), ]

# 3. Étiquettes de trimestres ("T3-2026") ------------------------------------
annee_ea <- as.integer(format(pib_ok$time, "%Y"))
mois_ea  <- as.integer(format(pib_ok$time, "%m"))
num_ea   <- annee_ea * 12 + mois_ea
lab_ea   <- lab_trim_mois(num_ea)

# 4. Glissement annuel --------------------------------------------------------
ea_niv <- pib_ok$values
names(ea_niv) <- lab_ea
ea_gl <- gl(ea_niv)
names(ea_gl) <- names(ea_niv)

# 5. Contrôles ----------------------------------------------------------------
stopifnot(!is.unsorted(pib_ok$time),
          length(ea_gl) >= 127,
          sum(!is.finite(ea_gl)) == 4,
          names(ea_gl)[1] == "T1-1995")
