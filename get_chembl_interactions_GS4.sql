SELECT   td.chembl_id, md.chembl_id, MIN(pp.accession), MIN(pp.description), GROUP_CONCAT(DISTINCT do.source_domain_id), MIN(act.standard_value),AVG(act.standard_value) , MAX(act.standard_value), MIN(canonical_smiles),MIN(pp.organism), MAX(md.max_phase), MAX(pp.sequence), MAX(act.standard_relation), MAX(act.activity_comment)
FROM assays
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
        AND td.organism IN ("homo sapiens")                                                               -- Organismos comunes para estudio con fármacos
        AND assays.confidence_score  > 8
        AND assays.assay_type = "B"
        AND act.standard_type IN ("Kd","Ki","EC50","IC50")                                                -- Otras formas de escribir IC50
        AND act.standard_units = "nM"                                                                     -- nM como unidad de medida
        AND substring_index(trim(substring_index(substring_index(molfile,"\n",4),"\n",-1))," ",1) < 80    -- Átomos pesados menor a "80"
        AND substring_index(trim(substring_index(substring_index(molfile,"\n",4),"\n",-1))," ",1) > 5     -- Átomos pesados mayor a "5"
        AND (act.standard_relation IS NULL OR act.standard_relation IN ("<","<<","<=","=","=="))          -- Ignorar casos donde el valor real no corresponde al valor anotado.
        AND (act.activity_comment IS NULL OR act.activity_comment NOT IN ("Not Active","Inactive","Inconclusive","Not Active (inhibition < 50% @ 10 uM and thus dose-reponse curve not measured)","Not Determined","No effect","Not evaluated","No inhibition","No activity","is not an inhibitor[-]"))                                   -- Ignorar casos donde el comentario de actividad indica que el compuesto no es activo.

    GROUP BY td.chembl_id,md.chembl_id                                                                    -- Agrupar por par proteína-ligando
        HAVING MAX(act.standard_value) < 10000                                                            -- 10 uM como tope.
        AND MAX(act.standard_value) > 0                                                                   -- 0 uM como piso, ignora anotaciones malas / erroneas (valores negativos, por ejemplo.)



-- #### TOOLS ####
-- SELECT count(*) AS cnt, organism FROM `target_dictionary` GROUP BY organism ORDER BY cnt DESC ### Muestra organismos en target_dictionary
-- SELECT   td.chembl_id, md.chembl_id, MIN(pp.accession), MIN(pp.description), GROUP_CONCAT(DISTINCT do.source_domain_id), MIN(act.standard_value),AVG(act.standard_value) , MAX(act.standard_value), MIN(canonical_smiles),MIN(pp.organism), MAX(md.max_phase), MAX(pp.sequence), MIN(cp.heavy_atoms), MIN(cp.full_mwt) ### Agrega columnas con cantidad de atomos pesados y peso molecular a query Gold_Standard.
--
