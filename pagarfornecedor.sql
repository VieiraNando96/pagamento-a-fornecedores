WITH tratar_cnpj AS (
    SELECT
        id,
        CASE WHEN Length(f.cnpj::text) > 11 THEN
            Lpad(f.cnpj::text, 14, '0')
        ELSE
            Lpad(f.cnpj::text, 11, '0')
        END AS "CNPJ/CPF_RAW",
        CASE WHEN Length(f.cnpj::text) > 11 THEN
            substring(Lpad(f.cnpj::text, 14, '0')
                FROM 1 FOR 2) || '.' || substring(lpad(f.cnpj::text, 14, '0')
                FROM 3 FOR 3) || '.' || substring(lpad(f.cnpj::text, 14, '0')
                FROM 6 FOR 3) || '/' || substring(lpad(f.cnpj::text, 14, '0')
                FROM 9 FOR 4) || '-' || substring(lpad(f.cnpj::text, 14, '0')
                FROM 13 FOR 2)
        ELSE
            substring(lpad(f.cnpj::text, 11, '0')
                FROM 1 FOR 3) || '.' || substring(lpad(f.cnpj::text, 11, '0')
                FROM 4 FOR 3) || '.' || substring(lpad(f.cnpj::text, 11, '0')
                FROM 7 FOR 3) || '-' || substring(lpad(f.cnpj::text, 11, '0')
                FROM 10 FOR 2)
        END AS cnpj_cpf
    FROM
        fornecedor f
)
SELECT
    pf.numerodocumento AS "Documento",
    pfp.numeroparcela,
    pf.id_loja AS "Filial",
    te.descricao AS "Tipo",
    f.id AS "Codigo Fornecedor",
    f.razaosocial AS "Nome Fornecedor",
    tcnpj.cnpj_cpf "CNPJ/CPF",
    pf.dataemissao AS "Emissão",
    pfp.datavencimento AS "Venc",
    pfp.datapagamento AS "Data Pagamento",
    cast(pfp.valor AS money) AS "Valor",
    cast(pfp.valoracrescimo AS money) AS "Juros/Multa",
    max(pfpa.valor) AS "Desconto",
    cast(pfp.valor + pfp.valoracrescimo - COALESCE(max(pfpa.valor), 0) AS money) AS "Valor Liquido",
    b.descricao AS "Conta"
FROM
    pagarfornecedor pf
    INNER JOIN pagarfornecedorparcela pfp ON pf.id = pfp.id_pagarfornecedor
    INNER JOIN tipoentrada te ON pf.id_tipoentrada = te.id
    INNER JOIN fornecedor f ON pf.id_fornecedor = f.id
    INNER JOIN tratar_cnpj tcnpj ON f.id = tcnpj.id
    LEFT JOIN pagarfornecedorparcelaabatimento pfpa ON pfp.id = pfpa.id_pagarfornecedorparcela
    LEFT JOIN banco b ON pfp.id_banco = b.id
WHERE
    pf.dataemissao BETWEEN '2023-09-01' AND '2023-11-30'
    AND pf.id_loja in (1,2)
    AND pfp.id_situacaopagarfornecedorparcela = 1
GROUP BY
    pf.numerodocumento,
    pfp.numeroparcela,
    pf.id_loja,
    te.descricao,
    f.id,
    f.razaosocial,
    f.cnpj,
    pf.dataemissao,
    pfp.datavencimento,
    pfp.datapagamento,
    pfp.valor,
    pfp.valoracrescimo,
    b.descricao,
    tcnpj.cnpj_cpf;

