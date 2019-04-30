-- table of values to potentially include
-- CREATE TEMPORARY TABLE tmp_inter
    --  SELECT  td.tid, cp.molregno, canonical_smiles, organism
--    SELECT DISTINCT(concat(assays.assay_id,"_", td.tid, "_",  cp.molregno)) as uniq_inter_id, assays.assay_id, td.tid,td.pref_name, pp.accession, pp.description, do.source_domain_id, act.standard_value, cp.molregno, canonical_smiles, pp.organism  
--     SELECT  assays.assay_id,  MIN(act.standard_value),AVG(act.standard_value) AS avg_val, MAX(act.standard_value)  
--    SELECT  assays.assay_id, td.tid, pp.accession, pp.description, do.source_domain_id, MIN(act.standard_value),AVG(act.standard_value) AS avg_val, MAX(act.standard_value), cp.molregno, md.chembl_id, ms.synonyms, canonical_smiles, pp.organism -- por alguna razon esto arroja error 
    SELECT   td.chembl_id, md.chembl_id, MIN(pp.accession), MIN(pp.description), GROUP_CONCAT(DISTINCT do.source_domain_id), MIN(act.standard_value),AVG(act.standard_value) , MAX(act.standard_value), MIN(canonical_smiles),MIN(pp.organism), MAX(md.max_phase),MIN(cp.heavy_atoms) -- por alguna razon esto arroja error 
     FROM assays
INNER JOIN activities  as act ON assays.assay_id = act.assay_id -- maestra tabla de interaaciones proteina-ligando
INNER JOIN confidence_score_lookup as csl 
INNER JOIN target_dictionary   as td  ON assays.tid = td.tid -- datos proteina target
LEFT JOIN target_components   as tc  ON td.tid = tc.tid -- datos proteina
LEFT JOIN component_sequences   as pp  ON tc.component_id = pp.component_id -- datos proteina
LEFT JOIN component_domains   as cd  ON pp.component_id = cd.component_id -- datos proteina
LEFT JOIN domains   as do  ON cd.domain_id = do.domain_id -- datos proteina
INNER JOIN compound_properties as cp  ON act.molregno = cp.molregno -- datos ligando
LEFT JOIN compound_structures as cs  ON act.molregno = cs.molregno -- datos ligando
LEFT JOIN molecule_dictionary as md  ON act.molregno = md.molregno -- datos ligando
LEFT JOIN molecule_synonyms as ms  ON act.molregno = ms.molregno -- datos ligando

     WHERE 1
	AND td.organism NOT IN ("homo sapiens")
      -- AND td.organism IN ("homo sapiens")
      -- AND td.target_type IN ("single protein", "protein complex")
--       AND assays.confidence_score  > 3 -- esta linea deberia ser equivalente a la anterior ya que 4 es se sabe que el target es parte de un complejo de proteinas homologas, pero no lo es, con esto salen mas resultados
--       AND assays.assay_type = "B"
--       AND act.standard_type IN ("Kd","Ki","EC50","IC50")  -- hay otras formas de escribir IC50 
  --     AND (                                                      -- estas lineas son buggy porque si la relacion es > 100 nM, eso es un dato valido 
    --       (act.standard_relation IN ("<=","=","==") AND act.standard_value <  10000)
      --     OR
  --         (act.standard_relation IN ("<<","<")      AND act.standard_value <= 10000)
    --       )
--       AND act.standard_units = "nM"
       --  AND cp.heavy_atoms < 80
       AND substring_index(trim(substring_index(substring_index(molfile,"\n",4),"\n",-1))," ",1) < 80 -- esto deberia ser atomos pesados menor a 80
       -- AND NOT EXISTS(SELECT * FROM tmptbl INNER JOIN WHERE molregno = 4899918645646465456645645)
   GROUP BY td.chembl_id,md.chembl_id -- agrupar por par proteina ligando
-- GROUP BY act.assay_id 
--       HAVING MIN(act.standard_value) < 10000    -- esta linea define max o min en los archivos de salida
--       HAVING AVG(act.standard_value) < 10000 esta linea no funciona el AVG no funciona no entiendo porque.

;


-- ALTER TABLE tmp_inter ADD PRIMARY KEY (assays.assay_id)
-- ;
-- SELECT * FROM tmp_inter;

 
--  paper 2013 (chembl_15):
--  347889 interactions, 1700 human proteins (1627) or protein complexes (73) and 224 412 molecules 
--  human only

--  paper 2014 (chembl_16):
--  280 381 small molecules interacting with 2686 targets
--  human, mouse, rat, cow and horse


