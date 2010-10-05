RegEmailName   = '[\w\.%\+\-]+'
RegDomainHead  = '(?:[A-Z0-9\-]+\.)+'
RegDomainTLD   = '(?:[A-Z]{2}|biz|com|info|name|net|org|pro|aero|asia|cat|coop|edu|gov|int|jobs|mil|mobi|museum|tel|travel|arpa|nato)'
RegEmailOk     = /\A#{RegEmailName}@#{RegDomainHead}#{RegDomainTLD}\z/i
