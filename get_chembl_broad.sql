SELECT   td.chembl_id, md.chembl_id, MIN(pp.accession), MIN(pp.description), GROUP_CONCAT(DISTINCT do.source_domain_id), MIN(act.standard_value),AVG(act.standard_value) , MAX(act.standard_value), MIN(canonical_smiles),MIN(pp.organism), MAX(md.max_phase),MIN(cp.heavy_atoms) 

FROM assays
INNER JOIN activities                as act ON assays.assay_id = act.assay_id
INNER JOIN confidence_score_lookup   as csl 
INNER JOIN target_dictionary         as td  ON assays.tid = td.tid
LEFT JOIN target_components          as tc  ON td.tid = tc.tid
LEFT JOIN component_sequences        as pp  ON tc.component_id = pp.component_id
LEFT JOIN component_domains          as cd  ON pp.component_id = cd.component_id
LEFT JOIN domains                    as do  ON cd.domain_id = do.domain_id
INNER JOIN compound_properties       as cp  ON act.molregno = cp.molregno
LEFT JOIN compound_structures        as cs  ON act.molregno = cs.molregno
LEFT JOIN molecule_dictionary        as md  ON act.molregno = md.molregno
LEFT JOIN molecule_synonyms          as ms  ON act.molregno = ms.molregno

WHERE 1
AND td.organism NOT IN ("homo sapiens")
AND substring_index(trim(substring_index(substring_index(molfile,"\n",4),"\n",-1))," ",1) < 80
GROUP BY td.chembl_id,md.chembl_id


