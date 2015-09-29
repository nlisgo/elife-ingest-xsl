<?xml version="1.0" encoding="UTF-8"?>
<stylesheet version="1.0"
            xmlns="http://www.w3.org/1999/XSL/Transform"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- documentation: http://www.refman.com/support/risformat_intro.asp -->
    <output method="text" encoding="utf-8"/>

    <template match="/">
        <apply-templates select="article/front/article-meta"/>
    </template>

    <template match="article-meta">
        <text>@article {</text>
        <value-of select="article-id[@pub-id-type='doi']"/>
        <text>,&#10;</text>
        <call-template name="item">
            <with-param name="key">author</with-param>
            <with-param name="value">
                <apply-templates select="contrib-group/contrib[@contrib-type='author']"/>
            </with-param>
        </call-template>
        <call-template name="item">
            <with-param name="key">editor</with-param>
            <with-param name="value">
                <apply-templates select="contrib-group/contrib[@contrib-type='editor']"/>
            </with-param>
        </call-template>
        <apply-templates select="title-group/article-title"/>
        <call-template name="item">
            <with-param name="key">volume</with-param>
            <with-param name="value"><call-template name="volume"/></with-param>
        </call-template>
        <call-template name="item">
            <with-param name="key">year</with-param>
            <with-param name="value"><call-template name="year"/></with-param>
        </call-template>
        <apply-templates select="pub-date[@date-type='pub']/month"/>
        <call-template name="item">
            <with-param name="key">pages</with-param>
            <with-param name="value" select="elocation-id"/>
        </call-template>
        <apply-templates select="article-id[@pub-id-type='doi']"/>
        <apply-templates select="../journal-meta/publisher/publisher-name"/>
        <apply-templates select="abstract[not(@abstract-type)]"/>
        <apply-templates select="../journal-meta/issn"/>
        <apply-templates select="../journal-meta/journal-title-group/journal-title"/>
        <call-template name="item">
            <with-param name="key">article_type</with-param>
            <with-param name="value">journal</with-param>
        </call-template>
        <apply-templates select="pub-date[@date-type='pub']"/>
        <call-template name="item">
            <with-param name="key">url</with-param>
            <with-param name="value" select="concat('https://dx.doi.org/', article-id[@pub-id-type='doi'])"/>
        </call-template>
        <apply-templates select="kwd-group[@kwd-group-type='author-keywords']"/>
        <call-template name="item">
            <with-param name="key">citation</with-param>
            <with-param name="value"><call-template name="citation"/></with-param>
            <with-param name="suffix" select="''"/>
        </call-template><!-- always at the end, to avoid trailing comma -->
        <text>}</text>
    </template>

    <template name="item">
        <param name="key"/>
        <param name="value"/>
        <param name="suffix" select="','"/>
        <value-of select="concat(' ', $key, ' = {', $value, '}', $suffix, '&#10;')"/>
    </template>

    <template match="article-id[@pub-id-type='doi']">
        <call-template name="item">
            <with-param name="key">doi</with-param>
            <with-param name="value" select="."/>
        </call-template>
    </template>

	<template match="article-title">
        <call-template name="item">
            <with-param name="key">title</with-param>
            <with-param name="value">
                <apply-templates mode="markup"/>
            </with-param>
        </call-template>
    </template>

    <template match="contrib-group[@content-type='authors']">
        <call-template name="item">
            <with-param name="key">author</with-param>
            <with-param name="value">
                <apply-templates select="contrib[@contrib-type='author']"/>
            </with-param>
        </call-template>
    </template>

    <!-- contributors (authors and editors) -->
	<template match="contrib">
        <choose>
            <when test="name">
                <value-of select="name/surname"/>
                <apply-templates select="name/suffix" mode="name"/>
                <apply-templates select="name/given-names" mode="name"/>
            </when>
        </choose>

        <if test="position() != last()">
            <value-of select="' and '"/>
        </if>
	</template>

    <template match="given-names | suffix" mode="name">
        <value-of select="concat(', ', .)"/>
    </template>

    <template match="kwd-group[@kwd-group-type='author-keywords']">
        <call-template name="item">
            <with-param name="key">keywords</with-param>
            <with-param name="value">
                <apply-templates select="kwd"/>
            </with-param>
        </call-template>
    </template>

    <template match="kwd">
        <value-of select="."/>

        <if test="position() != last()">
            <value-of select="', '"/>
        </if>
    </template>

    <template match="pub-date[@date-type='pub']">
        <call-template name="item">
            <with-param name="key">pub_date</with-param>
            <with-param name="value" select="concat(year, '-', month, '-', day)"/>
        </call-template>
    </template>

    <template match="pub-date[@date-type='pub']/year">
        <call-template name="item">
            <with-param name="key">year</with-param>
            <with-param name="value"><value-of select="."/></with-param>
        </call-template>
    </template>

    <template match="permissions/copyright-year">
        <call-template name="item">
            <with-param name="key">year</with-param>
            <with-param name="value"><value-of select="."/></with-param>
        </call-template>
    </template>

    <template match="pub-date[@date-type='pub']/month">
        <call-template name="item">
            <with-param name="key">month</with-param>
            <with-param name="value">
                <call-template name="month-abbrev-en">
                    <with-param name="MM" select="."/>
                </call-template>
            </with-param>
        </call-template>
    </template>

    <template match="year | month | volume">
        <call-template name="item">
            <with-param name="key" select="local-name()"/>
            <with-param name="value" select="."/>
        </call-template>
    </template>

    <template match="abstract">
        <variable name="text">
            <choose>
                <when test="object-id[@pub-id-type='doi']">
                    <variable name="newtext1">
                        <call-template name="string-replace-all">
                            <with-param name="text" select="."/>
                            <with-param name="replace" select="object-id[@pub-id-type='doi']"/>
                            <with-param name="by" select="''"/>
                        </call-template>
                    </variable>

                    <call-template name="string-replace-all">
                        <with-param name="text" select="$newtext1"/>
                        <with-param name="replace" select="'DOI: http://dx.doi.org/'"/>
                        <with-param name="by" select="''"/>
                    </call-template>
                </when>
                <otherwise>
                    <value-of select="."/>
                </otherwise>
            </choose>
        </variable>

        <call-template name="item">
            <with-param name="key">abstract</with-param>
            <with-param name="value" select="normalize-space($text)"/>
        </call-template>
    </template>

    <template match="elocation-id">
        <call-template name="item">
            <with-param name="key">pages</with-param>
            <with-param name="value" select="."/>
        </call-template>
    </template>

    <template match="publisher-name">
        <call-template name="item">
            <with-param name="key">publisher</with-param>
            <with-param name="value"><value-of select="."/></with-param>
        </call-template>
    </template>

    <template match="journal-title">
        <call-template name="item">
            <with-param name="key">journal</with-param>
            <with-param name="value" select="."/>
        </call-template>
    </template>

    <template match="issn">
        <call-template name="item">
            <with-param name="key">issn</with-param>
            <with-param name="value" select="."/>
        </call-template>
    </template>

    <!-- formatting markup -->
    <!-- see http://www.tei-c.org/release/doc/tei-xsl-common2/slides/teilatex-slides3.html -->

    <template match="*" mode="markup">
        <xsl:apply-templates mode="markup"/>
    </template>

    <template match="bold" mode="markup">
        <xsl:text>\textbf{</xsl:text>
        <xsl:apply-templates mode="markup"/>
        <xsl:text>}</xsl:text>
    </template>

    <template match="italic" mode="markup">
        <xsl:text>\textit{</xsl:text>
        <xsl:apply-templates mode="markup"/>
        <xsl:text>}</xsl:text>
    </template>

    <template match="underline" mode="markup">
        <xsl:text>\uline{</xsl:text>
        <xsl:apply-templates mode="markup"/>
        <xsl:text>}</xsl:text>
    </template>

    <template match="overline" mode="markup">
        <xsl:text>\textoverbar{</xsl:text>
        <xsl:apply-templates mode="markup"/>
        <xsl:text>}</xsl:text>
    </template>

    <template match="sup" mode="markup">
        <xsl:text>\textsuperscript{</xsl:text>
        <xsl:apply-templates mode="markup"/>
        <xsl:text>}</xsl:text>
    </template>

    <template match="sub" mode="markup">
        <xsl:text>\textsubscript{</xsl:text>
        <xsl:apply-templates mode="markup"/>
        <xsl:text>}</xsl:text>
    </template>

    <template match="sc" mode="markup">
        <xsl:text>\textsc{</xsl:text>
        <xsl:apply-templates mode="markup"/>
        <xsl:text>}</xsl:text>
    </template>

    <template match="monospace" mode="markup">
        <xsl:text>\texttt{</xsl:text>
        <xsl:apply-templates mode="markup"/>
        <xsl:text>}</xsl:text>
    </template>

    <template name="citation">
        <variable name="year"><call-template name="year"/></variable>
        <variable name="volume"><call-template name="volume"/></variable>
        <value-of select="concat(//journal-meta/journal-title-group/journal-title, ' ', $year, ';', $volume, ':', //article-meta/elocation-id)"/>
    </template>

    <template name="year">
        <choose>
            <when test="//article-meta/pub-date[@date-type='pub']/year">
                <value-of select="//article-meta/pub-date[@date-type='pub']/year"/>
            </when>
            <otherwise>
                <value-of select="//article-meta/permissions/copyright-year"/>
            </otherwise>
        </choose>
    </template>

    <template name="volume">
        <variable name="value">
            <choose>
                <when test="//article-meta/volume">
                    <value-of select="//article-meta/volume"/>
                </when>
                <otherwise>
                    <variable name="year"><call-template name="year"/></variable>
                    <value-of select="$year - 2011"/>
                </otherwise>
            </choose>
        </variable>
        <value-of select="$value"/>
    </template>

    <template name="month-abbrev-en">
        <param name="MM"/>
        <variable name="months" select="'  janfebmaraprmayjunjulaugsepoctnovdec'"/>
        <value-of select="substring($months, number($MM) * 3, 3)"/>
    </template>

    <template name="string-replace-all">
        <param name="text"/>
        <param name="replace"/>
        <param name="by"/>
        <choose>
            <when test="contains($text, $replace)">
                <value-of select="substring-before($text, $replace)"/>
                <value-of select="$by"/>
                <call-template name="string-replace-all">
                    <with-param name="text" select="substring-after($text, $replace)"/>
                    <with-param name="replace" select="$replace"/>
                    <with-param name="by" select="$by"/>
                </call-template>
            </when>
            <otherwise>
                <value-of select="$text"/>
            </otherwise>
        </choose>
    </template>
</stylesheet>
