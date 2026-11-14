# 03_commerce_exterieur.R
# Commerce extérieur : glissement annuel trimestriel par groupement d'utilisation

library(readxl)

# 1. Lecture -------------------------------------------------------------
chemin_ce <- "data/Projet DEPF.xlsx"
imp_brut <- read_excel(chemin_ce, sheet = 7, col_names = FALSE, col_types = "text")
exp_brut <- read_excel(chemin_ce, sheet = 8, col_names = FALSE, col_types = "text")

# 2. Mise en forme numérique ---------------------------------------------
mois_imp    <- unlist(imp_brut[1, -1], use.names = FALSE)
groupes_imp <- imp_brut[[1]][3:nrow(imp_brut)]
imp_num <- sapply(imp_brut[3:nrow(imp_brut), -1], as.numeric)
rownames(imp_num) <- groupes_imp
colnames(imp_num) <- mois_imp

mois_exp    <- unlist(exp_brut[1, -1], use.names = FALSE)
groupes_exp <- exp_brut[[1]][3:nrow(exp_brut)]
exp_num <- sapply(exp_brut[3:nrow(exp_brut), -1], as.numeric)
rownames(exp_num) <- groupes_exp
colnames(exp_num) <- mois_exp

motif <- "^[0-9]{4}M([1-9]|1[0-2])$"
stopifnot(all(grepl(motif, mois_imp)), all(grepl(motif, mois_exp)),
          dim(imp_num) == c(10, 144), dim(exp_num) == c(10, 144))

# 3. Ordre chronologique (le fichier va du plus récent au plus ancien) ----
imp_num <- imp_num[, rev(seq_len(ncol(imp_num)))]
exp_num <- exp_num[, rev(seq_len(ncol(exp_num)))]

num_mois <- as.integer(substr(colnames(imp_num), 1, 4)) * 12 +
  as.integer(sub(".*M", "", colnames(imp_num)))
stopifnot(all(diff(num_mois) == 1),
          identical(colnames(imp_num), colnames(exp_num)),
          imp_num["Total", "2025M12"] == 6698, imp_num["Total", "2014M1"] == 3951,
          exp_num["Total", "2025M12"] == 3840, exp_num["Total", "2014M1"] == 1759)

# 4. Trimestres ----------------------------------------------------------
annee  <- (num_mois - 1) %/% 12
mois_n <- (num_mois - 1) %% 12 + 1
trim   <- (mois_n - 1) %/% 3 + 1
lab_trim <- paste0("T", trim, "-", annee)
f_trim <- factor(lab_trim, levels = unique(lab_trim))

imp_trim <- t(apply(imp_num, 1, function(v) tapply(v, f_trim, sum)))
exp_trim <- t(apply(exp_num, 1, function(v) tapply(v, f_trim, sum)))

# 5. Trimestres complets -------------------------------------------------
manq_imp <- t(apply(imp_num, 1, function(v) tapply(v, f_trim, function(z) sum(is.na(z)))))
manq_exp <- t(apply(exp_num, 1, function(v) tapply(v, f_trim, function(z) sum(is.na(z)))))
compl_imp <- manq_imp == 0
compl_exp <- manq_exp == 0
stopifnot(dim(imp_trim) == c(10, 48), dim(exp_trim) == c(10, 48),
          sum(manq_imp["OR INDUSTRIEL", ]) == 24, sum(manq_exp["OR INDUSTRIEL", ]) == 22)

# 6. Glissement annuel en % (même unité que cibles) -----------------------
gl <- function(x) {
  n <- length(x)
  c(rep(NA, 4), 100 * (x[5:n] / x[1:(n - 4)] - 1))
}
imp_gl <- t(apply(imp_trim, 1, gl))
colnames(imp_gl) <- colnames(imp_trim)
exp_gl <- t(apply(exp_trim, 1, gl))
colnames(exp_gl) <- colnames(exp_trim)

# 7. Séries écartées -----------------------------------------------------
# OR INDUSTRIEL : trop de trimestres incomplets (import et export)
# EQUIPEMENT AGRICOLE (export) : série nulle sur 48 trimestres
imp_gl2 <- imp_gl[rownames(imp_gl) != "OR INDUSTRIEL", ]
exp_gl2 <- exp_gl[!(rownames(exp_gl) %in%
                      c("OR INDUSTRIEL", "PRODUITS FINIS D'EQUIPEMENT AGRICOLE")), ]

stopifnot(dim(imp_gl2) == c(9, 48), dim(exp_gl2) == c(8, 48),
          all(rowSums(!is.finite(imp_gl2)) == 4),
          all(rowSums(!is.finite(exp_gl2)) == 4))
