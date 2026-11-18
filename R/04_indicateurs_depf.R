# 04_indicateurs_depf.R
# Indicateurs mensuels/trimestriels (DEPF, ANRT) : glissement annuel trimestriel en %

library(readxl)

# Chemins : à adapter 
chemin_req  <- "data/requete_depf.xlsx"
chemin_anrt <- "data/anrt_observatoires.xlsx"

# 0. Fonctions communes -----------------------------------------------------
# Glissement annuel en % (identique à 03)
gl <- function(x) {
  n <- length(x)
  c(rep(NA, 4), 100 * (x[5:n] / x[1:(n - 4)] - 1))
}

# Numéro de mois (année * 12 + mois) -> étiquette de trimestre "T1-2026"
lab_trim_mois <- function(num) {
  annee <- (num - 1) %/% 12
  mois  <- (num - 1) %% 12 + 1
  paste0("T", (mois - 1) %/% 3 + 1, "-", annee)
}

# Série cumulée depuis janvier -> valeurs trimestrielles (cumuls de fin de trimestre)
cum_vers_trim <- function(cum, num) {
  annee <- (num - 1) %/% 12
  mois  <- (num - 1) %% 12 + 1
  fin   <- mois %% 3 == 0
  cq    <- cum[fin]
  q     <- mois[fin] / 3
  prev  <- c(NA, cq[-length(cq)])
  res   <- ifelse(q == 1, cq, cq - prev)
  names(res) <- paste0("T", q, "-", annee[fin])
  res
}

# Série mensuelle -> facteur de trimestres dans l'ordre chronologique
f_trim_mois <- function(num) {
  lab <- lab_trim_mois(num)
  factor(lab, levels = unique(lab))
}

# 1. Ciment (construction) : ventes mensuelles, somme par trimestre ----------
ciment_brut <- read_excel(chemin_req, sheet = "ciment", col_names = FALSE, col_types = "text")
i_tot    <- which(ciment_brut[[1]] == "TOTAL")[1]            # 1re ligne TOTAL = mensuelle
v_ciment <- as.numeric(unlist(ciment_brut[i_tot, -1]))
stopifnot(length(v_ciment) == 381, !anyNA(v_ciment))
num_c <- 1995 * 12 + 1 + 0:(length(v_ciment) - 1)            # janvier 1995 = 1er mois
ciment_trim <- tapply(v_ciment, f_trim_mois(num_c), sum)
ciment_gl <- gl(ciment_trim)
names(ciment_gl) <- names(ciment_trim)

# 2. Électricité (electricite_eau) : énergie nette appelée, cumul annuel -----
elec_brut <- read_excel(chemin_req, sheet = "publication ONE", col_names = FALSE, col_types = "text")
i_el   <- which(grepl("II- ENERGIE NETTE", elec_brut[[1]], fixed = TRUE))[1]
el_cum <- suppressWarnings(as.numeric(unlist(elec_brut[i_el, -1])))
stopifnot(length(el_cum) == 135, sum(is.na(el_cum)) == 1)    # avril 2016 vide (sans effet)
num_e   <- 2015 * 12 + 7 + 0:(length(el_cum) - 1)            # juillet 2015 = 1er mois
el_trim <- cum_vers_trim(el_cum, num_e)
el_gl <- gl(el_trim)
names(el_gl) <- names(el_trim)

# 3. Recettes touristiques (hebergement) : mensuel, somme par trimestre ------
rec_brut <- read_excel(chemin_req, sheet = "Recettes touristiques", col_names = FALSE, col_types = "text")
i_r   <- which(grepl("(mensuel)", rec_brut[[1]], fixed = TRUE))[1]
rec_m <- as.numeric(unlist(rec_brut[i_r, -1]))
stopifnot(length(rec_m) == 393, sum(is.na(rec_m)) == 6)      # T3-1994 et T3-2026 incomplets
num_r <- 1994 * 12 + 1 + 0:(length(rec_m) - 1)               # janvier 1994 = 1er mois
rec_trim <- tapply(rec_m, f_trim_mois(num_r), sum)           # NA si trimestre incomplet
rec_gl <- gl(rec_trim)
names(rec_gl) <- names(rec_trim)

# 4. Pêche (peche) : poids débarqué, cumul annuel ---------------------------
pe_brut <- read_excel(chemin_req, sheet = "Pêche", col_names = FALSE, col_types = "text")
i_p    <- which(grepl("Poids", pe_brut[[1]], fixed = TRUE))[1]
pe_cum <- suppressWarnings(as.numeric(unlist(pe_brut[i_p, -1])))
stopifnot(length(pe_cum) == 177, sum(is.na(pe_cum)) == 6)    # mois vides, aucun en fin de trimestre
num_p <- 2012 * 12 + 1 + 0:(length(pe_cum) - 1)              # janvier 2012 = 1er mois
pe_trim <- cum_vers_trim(pe_cum, num_p)
stopifnot(!anyNA(pe_trim))
pe_gl <- gl(pe_trim)
names(pe_gl) <- names(pe_trim)

# 5. Crédits bancaires (finance, immobilier) : encours, moyenne des 3 mois ---
cr_brut <- read_excel(chemin_req, sheet = "CB par objet économique", col_names = FALSE, col_types = "text")
i_cb <- which(grepl("Crédit bancaire", cr_brut[[1]], fixed = TRUE))[1]
i_ci <- which(grepl("Crédits immobiliers", cr_brut[[1]], fixed = TRUE))[1]
cb_m <- as.numeric(unlist(cr_brut[i_cb, -1]))
ci_m <- as.numeric(unlist(cr_brut[i_ci, -1]))
stopifnot(length(cb_m) == 298, !anyNA(cb_m), !anyNA(ci_m))
num_k <- 2001 * 12 + 12 + 0:(length(cb_m) - 1)               # décembre 2001 = 1er mois
f_k <- f_trim_mois(num_k)
n_k <- tapply(cb_m, f_k, length)
cb_trim <- tapply(cb_m, f_k, mean)
cb_trim[n_k < 3] <- NA                                       # T4-2001 : 1 seul mois
ci_trim <- tapply(ci_m, f_k, mean)
ci_trim[n_k < 3] <- NA
cb_gl <- gl(cb_trim)
names(cb_gl) <- names(cb_trim)
ci_gl <- gl(ci_trim)
names(ci_gl) <- names(ci_trim)

# 6. Dépenses de personnel de l'État (administration, educ_sante) : cumul ----
dp_brut <- read_excel(chemin_req, sheet = "Hors TVA CL", col_names = FALSE, col_types = "text")
i_d    <- which(grepl("Dépenses de personnel", dp_brut[[1]], fixed = TRUE))[1]
dp_cum <- as.numeric(unlist(dp_brut[i_d, -1]))
stopifnot(length(dp_cum) == 306, !anyNA(dp_cum))
num_d <- 2001 * 12 + 4 + 0:(length(dp_cum) - 1)              # avril 2001 = 1er mois
dp_trim <- cum_vers_trim(dp_cum, num_d)
dp_gl <- gl(dp_trim)
names(dp_gl) <- names(dp_trim)

# 7. Parc Internet global, ANRT (info_comm) : stock trimestriel -------------
pi_brut <- read_excel(chemin_anrt, sheet = "Parc_Internet", col_names = FALSE, col_types = "text")
i_h <- which(grepl("Période", pi_brut[[1]], fixed = TRUE))[1]
j_q <- which(unlist(pi_brut[i_h, ]) == "Q")                  # colonne Q = parc Internet global
pi_per <- pi_brut[[1]][(i_h + 1):nrow(pi_brut)]
pi_val <- as.numeric(pi_brut[[j_q]][(i_h + 1):nrow(pi_brut)])
names(pi_val) <- pi_per
stopifnot(length(pi_val) == 81, !anyNA(pi_val))
pi_gl <- gl(pi_val)
names(pi_gl) <- names(pi_val)

# 8. Regroupement : une série par indicateur (périodes différentes) ----------
indicateurs_gl <- list(
  ciment = ciment_gl, electricite = el_gl, recettes_tourisme = rec_gl,
  peche = pe_gl, credit_total = cb_gl, credit_immobilier = ci_gl,
  depenses_personnel = dp_gl, parc_internet = pi_gl
)
