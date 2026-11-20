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


tc_cim <- intersect(names(ciment_gl), colnames(cibles))
length(tc_cim)
head(tc_cim, 2)
tail(tc_cim, 2)
y_cim <- cibles["construction", tc_cim]
x_cim <- ciment_gl[tc_cim]
identical(names(y_cim), names(x_cim))
sum(is.na(y_cim))
sum(is.na(x_cim))
cor(y_cim, x_cim, use = "complete.obs")
sum(!is.na(y_cim))
covid <- c("T2-2020", "T3-2020", "T4-2020", "T1-2021", "T2-2021")
hors_covid <- !(names(y_cim) %in% covid)
cor(y_cim[hors_covid], x_cim[hors_covid], use = "complete.obs")
sum(!is.na(y_cim[hors_covid]))
x_cim_l1 <- c(NA, x_cim[-length(x_cim)])
names(x_cim_l1) <- names(x_cim)
cor(y_cim[hors_covid], x_cim_l1[hors_covid], use = "complete.obs")
sum(!is.na(y_cim[hors_covid]) & !is.na(x_cim_l1[hors_covid]))
d_cim <- data.frame(y = y_cim[hors_covid], x = x_cim[hors_covid])
m_cim <- lm(y ~ x, data = d_cim)
coef(m_cim)
summary(m_cim)$r.squared



carte <- list(
  construction    = "ciment",
  electricite_eau = "electricite",
  peche           = "peche",
  immobilier      = "credit_immobilier",
  finance         = "credit_total",
  administration  = "depenses_personnel",
  hebergement     = "recettes_tourisme",
  info_comm       = "parc_internet"
)

all(unlist(carte) %in% names(indicateurs_gl))
all(names(carte) %in% rownames(cibles))

for (s_al in names(carte)) {
  ind_al <- indicateurs_gl[[carte[[s_al]]]]
  tc_al  <- intersect(names(ind_al), colnames(cibles))
  ok_al  <- is.finite(cibles[s_al, tc_al]) & is.finite(ind_al[tc_al])
  cat(s_al, length(tc_al), sum(ok_al), "\n")
}
