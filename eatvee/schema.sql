CREATE TABLE `link_finder` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(16) DEFAULT 'new',
  `extract_url` varchar(256) DEFAULT NULL,
  `misc` text,
  `site` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `extract_url` (`extract_url`)
);

CREATE TABLE `restaurant_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  `website` varchar(64) DEFAULT NULL,
  `city` varchar(64) DEFAULT NULL,
  `phone` varchar(64) DEFAULT NULL,
  `address` varchar(64) DEFAULT NULL,
  `menu_link` varchar(256) DEFAULT NULL,
  `misc` text,
  `state` varchar(64) DEFAULT NULL,
  `site` varchar(64) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(16) DEFAULT 'new',
  `full_html` text,
  PRIMARY KEY (`id`)
);
