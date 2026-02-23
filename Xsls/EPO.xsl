<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mstns="http://msepo.gov.pl/epo/XSD/KartaEPO.xsd"
    exclude-result-prefixes="mstns">

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

	<xsl:template match="/">
		<html>
			<head>
				<meta charset="UTF-8"/>
				<title>Karta EPO</title>
				<style>
					body { font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px; }
					h1 { color: #1a4d80; }
					h2 { background:#e6f2ff; padding:6px 10px; border-radius:5px; margin-top:25px; }
					table { border-collapse: collapse; width: 90%; margin-bottom: 25px; background: #fff; box-shadow: 0 0 5px #ccc;}
					th, td { border: 1px solid #ccc; padding: 8px; text-align: left; vertical-align: top; }
					th { background-color: #f2f2f2; width: 25%; }
					.signature { border: 1px solid #888; padding: 10px; background: #fafafa; display: inline-block; margin-top: 2px; margin-bottom: 6px; }
					.signature img { display: block; max-width: 400px; margin-bottom: 5px; }
					.sig-label { font-weight: bold; text-align: center; margin-top: 5px; }
					.sig-date { font-size:12px; color:#555; text-align:center; }
				</style>
			</head>
			<body>
				<h1>Karta EPO</h1>
				<xsl:apply-templates select="mstns:TabletKartaEpo"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="mstns:TabletKartaEpo">

		<h2>Dane ogólne</h2>
		<table>
			<tr>
				<th>Data utworzenia karty</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:CreationDate"/>
					</xsl:call-template>
				</td>
			</tr>

		</table>

		<xsl:apply-templates select="mstns:TabletPrzesylki/mstns:TabletPrzesylkaPodpis/mstns:TabletPrzesylka"/>
	</xsl:template>

	<xsl:template match="mstns:TabletPrzesylka">
		<table>

			<xsl:if test="string-length(normalize-space(*[local-name()='IDPrzesylka'])) &gt; 0">
				<tr>
					<th>ID Przesyłki</th>
					<td>
						<xsl:value-of select="*[local-name()='IDPrzesylka']"/>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(*[local-name()='NumerNadania'])) &gt; 0">
				<tr>
					<th>Numer nadania</th>
					<td>
						<xsl:value-of select="*[local-name()='NumerNadania']"/>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(*[local-name()='DataNadania'])) &gt; 0">
				<tr>
					<th>Data nadania</th>
					<td>
						<xsl:call-template name="format-date">
							<xsl:with-param name="datetime" select="*[local-name()='DataNadania']"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(mstns:Rodzaj)) &gt; 0">

				<tr>
					<th>Rodzaj przesyłki</th>
					<td>
						<xsl:value-of select="mstns:Rodzaj"/>
					</td>
				</tr>
			</xsl:if>
		</table>
		<table>
			
			<tr>
				<th>Adresat</th>
				<td>
					<xsl:value-of select="mstns:Adresat"/>
				</td>
			</tr>
			<tr>
				<th>Kod pocztowy</th>
				<td>
					<xsl:value-of select="mstns:KodPocztowy"/>
				</td>
			</tr>
			<tr>
				<th>Miejscowość</th>
				<td>
					<xsl:value-of select="mstns:Miejscowosc"/>
				</td>
			</tr>
			<tr>
				<th>Ulica</th>
				<td>
					<xsl:value-of select="mstns:Ulica"/>
				</td>
			</tr>
			<tr>
				<th>Numer</th>
				<td>
					<xsl:value-of select="mstns:Dom"/>
					<xsl:if test="string-length(normalize-space(mstns:Lokal)) &gt; 0">
						<xsl:text> / </xsl:text>
						<xsl:value-of select="mstns:Lokal"/>
					</xsl:if>
				</td>
			</tr>

		</table>

		<h2>Informacje o odbiorze</h2>

		<table>
			<tr>
				<th>Status</th>
				<td>
					<xsl:choose>
						<xsl:when test="mstns:StatusPrzesylki=2">Doręczona</xsl:when>
						<xsl:when test="mstns:StatusPrzesylki=4">Brak doręczenia</xsl:when>
						<xsl:when test="mstns:StatusPrzesylki=5">Wydana (po awizo)</xsl:when>
						<xsl:when test="mstns:StatusPrzesylki=6">Zwrot (po awizo)</xsl:when>
						<xsl:otherwise>Nieznany</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>

			<!-- ODBIORCA (tylko dla 2 i 5) -->
			<xsl:if test="mstns:StatusPrzesylki=2 or mstns:StatusPrzesylki=5">
				<tr>
					<th>Odbiorca</th>
					<td>
						<xsl:choose>

							<!-- STATUS 2 -->
							<xsl:when test="mstns:StatusPrzesylki=2">
								<xsl:choose>
									<xsl:when test="mstns:OdbiorcaPrzesylki=0">Adresat</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=1">Dorosły domownik</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=2">Dozorca</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=3">Sołtys</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=4">Administracja domu</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=5">Upoważniony pracownik</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=6">Przełożony żołnierza</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=7">Przełożony funkcjonariusza Policji</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=8">Przełożony funkcjonariusza Agencji Bezpieczeństwa Wewnętrznego</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=9">Przełożony funkcjonariusza Agencji Wywiadu</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=10">Przełożony funkcjonariusza Służby Kontrwywiadu Wojskowego</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=11">Przełożony funkcjonariusza Służby Wywiadu Wojskowego</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=12">Przełożony funkcjonariusza Straży Granicznej</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=13">Przełożony funkcjonariusza Służby Celnej</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=14">Przełożony funkcjonariusza Centralnego Biura Antykorupcyjnego</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=15">Przełożony funkcjonariusza Służby Więziennej</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=16">Przedstawiciel ustawowy adresata</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=20">Adresat, który nie mógł lub odmówił pokwitowania odbioru przesyłki</xsl:when>
								</xsl:choose>
							</xsl:when>

							<!-- STATUS 5 -->
							<xsl:when test="mstns:StatusPrzesylki=5">
								<xsl:choose>
									<xsl:when test="mstns:OdbiorcaPrzesylki=0">Adresat</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=1">Upoważniony pracownik</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=2">Osoba uprawniona do reprezentacji</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=3">Pełnomocnik pocztowy</xsl:when>
									<xsl:when test="mstns:OdbiorcaPrzesylki=4">Przedstawiciel ustawowy adresata</xsl:when>
								</xsl:choose>
							</xsl:when>

						</xsl:choose>
					</td>
				</tr>
			</xsl:if>

			<!-- IMIĘ I NAZWISKO (tylko gdy faktycznie było doręczenie lub wydanie) -->
			<xsl:if test="mstns:StatusPrzesylki=2 or mstns:StatusPrzesylki=5">
				<tr>
					<th>Imię i nazwisko odbiorcy</th>
					<td>
						<xsl:value-of select="mstns:ImieINazwiskoOdbiorcy"/>
					</td>
				</tr>
			</xsl:if>

			<!-- BRAK DORĘCZENIA (4 i 6) -->
			<xsl:if test="mstns:StatusPrzesylki=4 or mstns:StatusPrzesylki=6">
				<tr>
					<th>Powód braku doręczenia</th>
					<td>
						<xsl:choose>
							<xsl:when test="mstns:BrakDoreczenia=0">Adresat odmówił przyjęcia</xsl:when>
							<xsl:when test="mstns:BrakDoreczenia=1">Niepełny adres</xsl:when>
							<xsl:when test="mstns:BrakDoreczenia=2">
								Nie doręczono z innych przyczyn
								<xsl:value-of select="mstns:BrakDoreczeniaInnaPrzyczyna"/>
							</xsl:when>
							<xsl:when test="mstns:BrakDoreczenia=3">
								Nie podjęto przesyłki z placówki pocztowej/Urzędu Gminy
							</xsl:when>
						</xsl:choose>
					</td>
				</tr>
			</xsl:if>

			<tr>
				<th>Data odbioru</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:SystemowaDataOznaczenia"/>
					</xsl:call-template>
				</td>
			</tr>

			<!-- AWIZO – tylko jeśli pola istnieją -->

				<xsl:if test="string-length(normalize-space(mstns:DataAwizo1)) &gt; 0">
					<tr>
						<th>Data pierwszego awizo</th>
						<td>
							<xsl:call-template name="format-date">
								<xsl:with-param name="datetime" select="mstns:DataAwizo1"/>
							</xsl:call-template>
						</td>
					</tr>
				</xsl:if>

			<xsl:if test="string-length(normalize-space(mstns:DataAwizo2)) &gt; 0">
				<tr>
					<th>Data drugiego awizo</th>
					<td>
						<xsl:call-template name="format-date">
							<xsl:with-param name="datetime" select="mstns:DataAwizo2"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(mstns:DataZapisu)) &gt; 0">
				<tr>
					<th>Data zapisu</th>
					<td>
						<xsl:call-template name="format-date">
							<xsl:with-param name="datetime" select="mstns:DataZapisu"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>

		</table>

		<div class="signature">
			<strong>Podpis odbiorcy:</strong>

			<xsl:if test="string-length(normalize-space(mstns:Podpis)) &gt; 0">
				<img>
					<xsl:attribute name="src">
						<xsl:text>data:image/png;base64,</xsl:text>
						<xsl:value-of select="mstns:Podpis"/>
					</xsl:attribute>
				</img>
			</xsl:if>

			<div class="sig-label">
				<xsl:value-of select="mstns:ImieINazwiskoOdbiorcy"/>
			</div>

			<xsl:if test="string-length(normalize-space(mstns:DataPodpisu)) &gt; 0">
				<div class="sig-date">
					Data podpisu:
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DataPodpisu"/>
					</xsl:call-template>
				</div>
			</xsl:if>

		</div>

	</xsl:template>

</xsl:stylesheet>
