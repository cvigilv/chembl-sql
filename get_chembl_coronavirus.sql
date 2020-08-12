
SELECT   td.chembl_id, md.chembl_id, MIN(pp.accession), MIN(pp.description), GROUP_CONCAT(DISTINCT do.source_domain_id), MIN(act.standard_value),AVG(act.standard_value) , MAX(act.standard_value), MIN(canonical_smiles),MIN(pp.organism), MAX(md.max_phase), MAX(pp.sequence), MAX(act.standard_relation), MAX(act.activity_comment)
--FROM assays
INNER JOIN activities              as act ON assays.assay_id = act.assay_id        -- Tabla maestra para interacciones proteina-ligando
INNER JOIN confidence_score_lookup as csl
INNER JOIN target_dictionary       as td  ON assays.tid = td.tid                   -- Datos: Proteina "Target"
LEFT JOIN target_components        as tc  ON td.tid = tc.tid                       -- Datos: Proteina
LEFT JOIN component_sequences      as pp  ON tc.component_id = pp.component_id     -- Datos: Proteina
LEFT JOIN component_domains        as cd  ON pp.component_id = cd.component_id     -- Datos: Proteina
LEFT JOIN domains                  as do  ON cd.domain_id = do.domain_id           -- Datos: Proteina
INNER JOIN compound_properties     as cp  ON act.molregno = cp.molregno            -- Datos: Ligando
LEFT JOIN compound_structures      as cs  ON act.molregno = cs.molregno            -- Datos: Ligando
LEFT JOIN molecule_dictionary      as md  ON act.molregno = md.molregno            -- Datos: Ligando
LEFT JOIN molecule_synonyms        as ms  ON act.molregno = ms.molregno            -- Datos: Ligando

    WHERE 1
        AND (pp.description IS NULL OR pp.description IN ("coronavirus"))
        AND (td.organism LIKE "%coronavirus%")

    GROUP BY td.chembl_id,md.chembl_id                                                                    -- Agrupar por par proteína-ligando



-- #### TOOLS ####
-- SELECT count(*) AS cnt, organism FROM `target_dictionary` GROUP BY organism ORDER BY cnt DESC ### Muestra organismos en target_dictionary
-- SELECT   td.chembl_id, md.chembl_id, MIN(pp.accession), MIN(pp.description), GROUP_CONCAT(DISTINCT do.source_domain_id), MIN(act.standard_value),AVG(act.standard_value) , MAX(act.standard_value), MIN(canonical_smiles),MIN(pp.organism), MAX(md.max_phase), MAX(pp.sequence), MIN(cp.heavy_atoms), MIN(cp.full_mwt) ### Agrega columnas con cantidad de atomos pesados y peso molecular a query Gold_Standard.
--
