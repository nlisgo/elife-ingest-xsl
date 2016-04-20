<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:output method="text" encoding="utf-8"/>

    <xsl:template match="/">
        <xsl:text>{&#10;</xsl:text>
        <xsl:call-template name="collection">
            <xsl:with-param name="prefix" select="''"/>
            <xsl:with-param name="key">references</xsl:with-param>
            <xsl:with-param name="value"><xsl:apply-templates select="//ref-list/ref/element-citation"/></xsl:with-param>
            <xsl:with-param name="value_prefix" select="'['"/>
            <xsl:with-param name="value_suffix" select="']'"/>
        </xsl:call-template>
        <xsl:text>&#10;}</xsl:text>
    </xsl:template>

    <xsl:template name="item">
        <xsl:param name="prefix" select="',&#10;'"/>
        <xsl:param name="key"/>
        <xsl:param name="value" select="''"/>
        <xsl:param name="default_value" select="''"/>
        <xsl:param name="string" select="'true'"/>
        <xsl:if test="normalize-space($value) != '' or $default_value != ''">
            <xsl:value-of select="$prefix"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$key"/>
            <xsl:text>": </xsl:text>
            <xsl:choose>
                <xsl:when test="normalize-space($value) != ''">
                    <xsl:if test="$string = 'true'">
                        <xsl:text>"</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="$value"/>
                    <xsl:if test="$string = 'true'">
                        <xsl:text>"</xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default_value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="collection">
        <xsl:param name="force" select="0"/>
        <xsl:param name="prefix" select="',&#10;'"/>
        <xsl:param name="key" select="''"/>
        <xsl:param name="value"/>
        <xsl:param name="value_prefix" select="'{'"/>
        <xsl:param name="value_suffix" select="'}'"/>
        <xsl:if test="$value != '' or $force != 0">
            <xsl:if test="$prefix != ''">
                <xsl:value-of select="$prefix"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$key != ''">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="$key"/>
                    <xsl:text>": </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$value_prefix"/>
            <xsl:if test="$value != ''">
                <xsl:value-of select="'&#10;'"/>
                <xsl:value-of select="$value"/>
                <xsl:value-of select="'&#10;'"/>
            </xsl:if>
            <xsl:value-of select="$value_suffix"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="element-citation">
        <xsl:variable name="titleLink">
            <xsl:choose>
                <xsl:when test="pub-id">
                    <xsl:value-of select="concat('http://dx.doi.org/', pub-id)"/>
                </xsl:when>
                <xsl:when test=".//ext-link/@xlink:href">
                    <xsl:value-of select=".//ext-link/@xlink:href"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="secondaryLinkText">
            <xsl:choose>
                <xsl:when test="pub-id">
                    <xsl:value-of select="concat('http://dx.doi.org/', pub-id)"/>
                </xsl:when>
                <xsl:when test=".//ext-link/@xlink:href = concat('http://dx.doi.org/', .//ext-link)">
                    <xsl:value-of select=".//ext-link/@xlink:href"/>
                </xsl:when>
                <xsl:when test=".//ext-link">
                    <xsl:value-of select=".//ext-link"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="originPrepare">
            <xsl:if test="child::article-title and child::source">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="child::source"/>
            </xsl:if>
            <xsl:if test="child::publisher-name">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="child::publisher-name"/>
            </xsl:if>
            <xsl:if test="child::publisher-loc">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="child::publisher-loc"/>
            </xsl:if>
            <xsl:if test="child::volume">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="child::volume"/>
            </xsl:if>
            <xsl:if test="child::fpage">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="child::fpage"/>
                <xsl:if test="child::lpage">
                    <xsl:text>-</xsl:text>
                    <xsl:apply-templates select="child::lpage"/>
                </xsl:if>
            </xsl:if>
            <xsl:if test="child::year">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="child::year"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="origin">
            <xsl:if test="$originPrepare != ''">
                <xsl:value-of select="substring-after($originPrepare, ', ')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:call-template name="collection">
            <xsl:with-param name="prefix" select="''"/>
            <xsl:with-param name="value">
                <xsl:call-template name="collection">
                    <xsl:with-param name="prefix" select="''"/>
                    <xsl:with-param name="key">bibId</xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:call-template name="item">
                            <xsl:with-param name="prefix" select="''"/>
                            <xsl:with-param name="key">full</xsl:with-param>
                            <xsl:with-param name="value" select="parent::ref/@id"/>
                        </xsl:call-template>
                        <xsl:call-template name="item">
                            <xsl:with-param name="key">ordinal</xsl:with-param>
                            <xsl:with-param name="value" select="position()"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">titleLink</xsl:with-param>
                    <xsl:with-param name="value" select="$titleLink"/>
                </xsl:call-template>
                <xsl:if test="$titleLink != '' and $secondaryLinkText != ''">
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">secondaryLinkText</xsl:with-param>
                        <xsl:with-param name="value" select="$secondaryLinkText"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">title</xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:choose>
                            <xsl:when test="child::article-title">
                                <xsl:apply-templates select="child::article-title" mode="formatting"/>
                            </xsl:when>
                            <xsl:when test="child::source">
                                <xsl:apply-templates select="child::source" mode="formatting"/>
                            </xsl:when>
                            <xsl:when test="child::comment">
                                <xsl:apply-templates select="child::comment" mode="formatting"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">origin</xsl:with-param>
                    <xsl:with-param name="value" select="$origin"/>
                </xsl:call-template>
                <xsl:if test="person-group[@person-group-type]/name | person-group[@person-group-type]/collab">
                    <xsl:call-template name="collection">
                        <xsl:with-param name="key">authors</xsl:with-param>
                        <xsl:with-param name="value_prefix" select="'['"/>
                        <xsl:with-param name="value">
                            <xsl:apply-templates select="person-group[@person-group-type]/name | person-group[@person-group-type]/collab"/>
                        </xsl:with-param>
                        <xsl:with-param name="value_suffix" select="']'"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="position() != last()">
            <xsl:value-of select="',&#10;'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="person-group[@person-group-type]/name | person-group[@person-group-type]/collab">
        <xsl:variable name="authorNamePrepare">
            <xsl:choose>
                <xsl:when test="name() = 'collab'">
                    <xsl:value-of select="concat(., ' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="given-names">
                        <xsl:apply-templates select="given-names" mode="formatting"/>
                        <xsl:value-of select="' '"/>
                    </xsl:if>
                    <xsl:if test="surname">
                        <xsl:apply-templates select="surname" mode="formatting"/>
                        <xsl:value-of select="' '"/>
                    </xsl:if>
                    <xsl:if test="suffix">
                        <xsl:apply-templates select="suffix" mode="formatting"/>
                        <xsl:value-of select="' '"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="authorName">
            <xsl:if test="$authorNamePrepare != ''">
                <xsl:value-of select="substring($authorNamePrepare, 0, string-length($authorNamePrepare))"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="authorLink">
            <xsl:if test="$authorName != ''">
                <xsl:value-of select="concat('http://scholar.google.com/scholar?q=\&quot;author:', $authorName, '\&quot;')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:call-template name="collection">
            <xsl:with-param name="prefix" select="''"/>
            <xsl:with-param name="value">
                <xsl:call-template name="item">
                    <xsl:with-param name="key">authorName</xsl:with-param>
                    <xsl:with-param name="prefix" select="''"/>
                    <xsl:with-param name="value" select="$authorName"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">authorLink</xsl:with-param>
                    <xsl:with-param name="value" select="$authorLink"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="position() != last()">
            <xsl:value-of select="',&#10;'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="by"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text, $replace)"/>
                <xsl:value-of select="$by"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text, $replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="by" select="$by"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="formatting">
        <xsl:variable name="escape_backslash">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text"><xsl:apply-templates/></xsl:with-param>
                <xsl:with-param name="replace" select="'\'"/>
                <xsl:with-param name="by" select="'\\'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="escape_quotes">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$escape_backslash"/>
                <xsl:with-param name="replace" select="'&quot;'"/>
                <xsl:with-param name="by" select="'\&quot;'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="output" select="$escape_quotes"/>

        <xsl:value-of select="normalize-space($output)"/>
    </xsl:template>

    <xsl:template match="bold | italic | sup | sub">
        <xsl:variable name="el_name">
            <xsl:choose>
                <xsl:when test="name() = 'bold'">b</xsl:when>
                <xsl:when test="name() = 'italic'">i</xsl:when>
                <xsl:otherwise><xsl:value-of select="name()"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$el_name"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:apply-templates/><xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$el_name"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
