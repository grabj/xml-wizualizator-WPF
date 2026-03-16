<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mstns="KartaEPO/2018/07/15"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    exclude-result-prefixes="mstns ds">

	<xsl:output method="html" indent="yes" encoding="UTF-8"/>

	<!-- Format YYYY-MM-DD HH:MM:SS -->
	<xsl:template name="format-date">
		<xsl:param name="datetime"/>
		<xsl:if test="string-length(normalize-space($datetime)) &gt; 0">
			<xsl:value-of select="substring($datetime,1,10)"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="substring($datetime,12,8)"/>
		</xsl:if>
	</xsl:template>

	<!-- ROOT -->
	<xsl:template match="/">
		<html>
			<head>
				<meta charset="UTF-8"/>
				<title>EPO</title>
				<style>
					body { font-family: Arial, sans-serif; padding: 10px; }
					h1 { color:#1a4d80; }
					h2 { background:#e6f2ff; padding:4px 10px; border-radius:5px; margin-top:25px; }
					table { border-collapse: collapse; width: 100%; margin-bottom: 20px; box-shadow: 0 0 5px #ccc;}
					th, td { border: 1px solid #ccc; padding: 8px; text-align: left; vertical-align: top; }
					th { width: 30%; background:#f5f5f5; }
					.signature { border:1px solid #888; padding:10px; background:#fafafa; display:inline-block; margin-top:5px; }
					.signature img { max-width:400px; display:block; margin-bottom:5px; }
					.sig-date { font-size:12px; color:#555; text-align:center; }
				</style>
			</head>
			<body>

				<h1>Elektroniczne Potwierdzenie Odbioru</h1>

				<xsl:apply-templates select="mstns:KartaEpo"/>

			</body>
		</html>
	</xsl:template>

	<!-- KARTA EPO -->
	<xsl:template match="mstns:KartaEpo">

		<h2>Dane ogólne</h2>
		<table>
			<tr>
				<th>Data utworzenia EPO</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DataUtworzenia"/>
					</xsl:call-template>
				</td>
			</tr>
			<tr>
				<th>Id karty EPO</th>
				<td>
					<xsl:value-of select="mstns:IdKartyEPO"/>
				</td>
			</tr>
		</table>

		<xsl:apply-templates select="mstns:Przesylka"/>
		<xsl:apply-templates select="mstns:PrzesylkaPodpis"/>

	</xsl:template>

	<!-- PRZESYŁKA -->
	<xsl:template match="mstns:Przesylka">

		<h2>Dane przesyłki</h2>

		<table>

			<tr>
				<th>Id przesyłki</th>
				<td>
					<xsl:value-of select="mstns:IdPrzesylki"/>
				</td>
			</tr>

			<tr>
				<th>Numer nadania</th>
				<td>
					<xsl:value-of select="mstns:NumerNadania"/>
				</td>
			</tr>

			<tr>
				<th>Data nadania</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DataNadania"/>
					</xsl:call-template>
				</td>
			</tr>

			<tr>
				<th>Data pisma</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DataPisma"/>
					</xsl:call-template>
				</td>
			</tr>

			<tr>
				<th>Adresat</th>
				<td>
					<xsl:value-of select="mstns:Adresat/mstns:Nazwa"/>
					<br/>
					<xsl:value-of select="mstns:Adresat/mstns:Ulica"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns:Adresat/mstns:NumerDomu"/>
					<br/>
					<xsl:value-of select="mstns:Adresat/mstns:KodPocztowy"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns:Adresat/mstns:Miejscowosc"/>
				</td>
			</tr>

			<tr>
				<th>Nadawca</th>
				<td>
					<xsl:value-of select="mstns:Nadawca/mstns:Nazwa"/>
					<br/>
					<xsl:value-of select="mstns:Nadawca/mstns:Ulica"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns:Nadawca/mstns:NumerDomu"/>
					<br/>
					<xsl:value-of select="mstns:Nadawca/mstns:KodPocztowy"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns:Nadawca/mstns:Miejscowosc"/>
				</td>
			</tr>

			<tr>
				<th>Tryb doręczenia</th>
				<td>
					<xsl:value-of select="mstns:TrybDoreczenia"/>

					<xsl:if test="mstns:TrybDoreczenia/@DoRakWlasnych">
						<xsl:text> (Do rąk własnych: </xsl:text>

						<xsl:choose>
							<xsl:when test="mstns:TrybDoreczenia/@DoRakWlasnych='true'">TAK</xsl:when>
							<xsl:when test="mstns:TrybDoreczenia/@DoRakWlasnych='false'">NIE</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="mstns:TrybDoreczenia/@DoRakWlasnych"/>
							</xsl:otherwise>
						</xsl:choose>

						<xsl:text>)</xsl:text>
					</xsl:if>

				</td>
			</tr>

		</table>

	</xsl:template>

	<!-- PODPIS / ZWROT -->
	<xsl:template match="mstns:PrzesylkaPodpis">

		<xsl:variable name="adnotacja"
            select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora"/>

		<xsl:choose>

			<!-- ZWROT -->
			<xsl:when test="string-length(normalize-space($adnotacja/mstns:RodzajZwrot)) &gt; 0">

				<h2>Informacje o zwrocie</h2>

				<table>

					<tr>
						<th>Powód zwrotu</th>
						<td>
							<xsl:value-of select="$adnotacja/mstns:PowodZwrotu"/>
						</td>
					</tr>

					<tr>
						<th>Data zwrotu</th>
						<td>
							<xsl:call-template name="format-date">
								<xsl:with-param name="datetime"
                                    select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:DataZdarzenia"/>
							</xsl:call-template>
						</td>
					</tr>
				</table>

			</xsl:when>

			<!-- DORĘCZENIE -->
			<xsl:otherwise>

				<h2>Informacje o doręczeniu</h2>

				<table>
					<tr>
						<th>Rodzaj doręczenia</th>
						<td>
							<xsl:value-of select="$adnotacja/mstns:RodzajDoreczenie"/>
						</td>
					</tr>

					<tr>
						<th>Podmiot doręczenia</th>
						<td>
							<xsl:value-of select="$adnotacja/mstns:PodmiotDoreczenia"/>
						</td>
					</tr>
					
			<xsl:if test="string-length(normalize-space(mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora/mstns:TrescAdnotacji)) &gt; 0">
				<tr>
					<th>Odbiorca</th>
					<td>
						<xsl:value-of select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora/mstns:TrescAdnotacji"/>
					</td>
				</tr>
			</xsl:if>

					<tr>
						<th>Data doręczenia</th>
						<td>
							<xsl:call-template name="format-date">
								<xsl:with-param name="datetime"
                                    select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:DataZdarzenia"/>
							</xsl:call-template>
						</td>
					</tr>
				</table>

				<xsl:if test="string-length(normalize-space(mstns:PodpisObraz)) &gt; 0">
					<div class="signature">
						<strong>Podpis odbiorcy:</strong>

						<img>
							<xsl:attribute name="src">
								<xsl:text>data:image/png;base64,</xsl:text>
								<xsl:value-of select="mstns:PodpisObraz"/>
							</xsl:attribute>
						</img>
					</div>
				</xsl:if>

			</xsl:otherwise>

		</xsl:choose>

	</xsl:template>

</xsl:stylesheet>