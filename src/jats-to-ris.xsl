<?xml version="1.0" encoding="UTF-8"?>
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">
    <!-- documentation: http://www.refman.com/support/risformat_intro.asp -->
    <output method="text" encoding="utf-8"/>

    <template match="/">
        <apply-templates select="article/front/article-meta"/>
    </template>

    <template match="article-meta">
        <call-template name="item">
            <with-param name="key">TY</with-param>
            <with-param name="value">JOUR</with-param>
        </call-template>
        <apply-templates select="contrib-group/contrib"/>
        <apply-templates select="title-group/article-title"/>
        <apply-templates select="pub-date[@date-type='pub']"/>
        <apply-templates select="../journal-meta/journal-title-group/journal-title"/>
        <apply-templates select="../journal-meta/issn"/>
        <apply-templates select="../journal-meta/publisher/publisher-name"/>
        <apply-templates select="article-id[@pub-id-type='doi']"/>
        <apply-templates select="volume"/>
        <call-template name="item">
            <with-param name="key">UR</with-param>
            <with-param name="value" select="concat('http://elifesciences.org/content/', volume, '/', elocation-id)"/>
        </call-template>
        <call-template name="item">
            <with-param name="key">M3</with-param>
            <with-param name="value">JOUR</with-param>
        </call-template>
        <call-template name="item">
            <with-param name="key">C1</with-param>
            <with-param name="value" select="concat(../journal-meta/journal-title-group/journal-title, ' ', pub-date[@date-type='pub']/year, ';', volume, ':', elocation-id)"/>
        </call-template>
        <apply-templates select="kwd-group[@kwd-group-type='author']/kwd"/>
        <apply-templates select="abstract[not(@abstract-type)]"/>
        <text>ER  -&#32;</text><!-- space at the end, might not be necessary -->
        <text>&#10;</text><!-- newline -->
    </template>

    <template name="item">
        <param name="key"/>
        <param name="value" select="."/>
        <value-of select="concat($key, '  - ', $value, '&#10;')"/>
    </template>

    <template match="article-id[@pub-id-type='doi']">
        <call-template name="item">
            <with-param name="key">DO</with-param>
        </call-template>
    </template>

    <template match="article-title">
        <call-template name="item">
            <with-param name="key">TI</with-param>
        </call-template>
    </template>

    <!-- contributors (authors and editors) -->
    <template match="contrib">
        <variable name="type" select="@contrib-type"/>

        <variable name="tag">
            <choose>
                <when test="$type = 'author'">AU</when>
                <when test="$type = 'editor'">A2</when><!-- ED -->
                <otherwise>A3</otherwise>
            </choose>
        </variable>

        <choose>
            <when test="name">
                <call-template name="item">
                    <with-param name="key" select="$tag"/>
                    <with-param name="value">
                        <value-of select="name/surname"/>
                        <apply-templates select="name/given-names" mode="name"/>
                        <apply-templates select="name/suffix" mode="name"/>
                    </with-param>
                </call-template>
            </when>
        </choose>
    </template>

    <template match="given-names | suffix" mode="name">
        <value-of select="concat(', ', .)"/>
    </template>

    <template match="pub-date">
        <call-template name="item">
            <with-param name="key">PY</with-param>
            <with-param name="value" select="year"/>
        </call-template>
        <call-template name="item">
            <with-param name="key">DA</with-param>
            <with-param name="value" select="concat(year, '/', month, '/', day)"/>
        </call-template>
    </template>

    <template match="kwd">
        <call-template name="item">
            <with-param name="key">KW</with-param>
        </call-template>
    </template>

    <template match="abstract">
        <variable name="text" select="."/>

        <variable name="newtext1">
            <call-template name="string-replace-all">
                <with-param name="text" select="$text"/>
                <with-param name="replace" select="object-id[@pub-id-type='doi']"/>
                <with-param name="by" select="''"/>
            </call-template>
        </variable>

        <variable name="newtext2">
        <call-template name="string-replace-all">
            <with-param name="text" select="$newtext1"/>
            <with-param name="replace" select="'DOI: http://dx.doi.org/'"/>
            <with-param name="by" select="''"/>
        </call-template>
        </variable>

        <call-template name="item">
            <with-param name="key">AB</with-param>
            <with-param name="value" select="$newtext2"/>
        </call-template>
    </template>

    <template match="volume">
        <call-template name="item">
            <with-param name="key">VL</with-param>
        </call-template>
    </template>

    <template match="elocation-id">
        <call-template name="item">
            <with-param name="key">SP</with-param>
        </call-template>
    </template>

    <template match="publisher-name">
        <call-template name="item">
            <with-param name="key">PB</with-param>
        </call-template>
    </template>

    <template match="journal-title">
        <call-template name="item">
            <with-param name="key">JF</with-param>
        </call-template>
    </template>

    <template match="issn">
        <call-template name="item">
            <with-param name="key">SN</with-param>
        </call-template>
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
