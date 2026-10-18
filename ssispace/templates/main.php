<?php

declare(strict_types=1);

/** @var \OCP\IL10N $l */

?>
<div id="app-content">
<div id="app-content-wrapper">
<div id="ssispace" class="ssispace" aria-busy="true" data-files-base="<?php p($_['urlFilesBase']); ?>">
	<h2 class="ssispace-title"><?php p($l->t('Spaces')); ?></h2>

	<section class="ssispace-section">
		<h3><?php p($l->t('My space')); ?></h3>
		<div class="ssispace-cards">
			<a class="ssispace-card ssispace-card--wide" href="<?php p($_['urlMySpace']); ?>">
				<span class="ssispace-card-icon" aria-hidden="true">
					<svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><path d="M20 6h-8l-2-2H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2z"/></svg>
				</span>
				<span class="ssispace-card-body">
					<span class="ssispace-card-name"><?php p($l->t('Personal files')); ?></span>
					<span class="ssispace-card-meta"><?php p($l->t('All your files in one place')); ?></span>
				</span>
			</a>
		</div>
	</section>

	<section class="ssispace-section">
		<h3><?php p($l->t('Department spaces')); ?></h3>
		<p class="ssispace-section-sub"><?php p($l->t('Team folders you can access, grouped by department')); ?></p>
		<div id="ssispace-depts" class="ssispace-cards">
			<div class="ssispace-skel" aria-hidden="true"></div>
			<div class="ssispace-skel" aria-hidden="true"></div>
		</div>
		<p id="ssispace-depts-empty" class="ssispace-empty" hidden><?php p($l->t('No department spaces yet. When your department creates team folders, they will appear here.')); ?></p>
		<p id="ssispace-depts-error" class="ssispace-empty" hidden><?php p($l->t('Could not load spaces. Please refresh the page.')); ?></p>
	</section>

	<section class="ssispace-section">
		<h3><?php p($l->t('Shared with me')); ?></h3>
		<p class="ssispace-section-sub"><?php p($l->t('Files and folders others shared with you')); ?></p>
		<div id="ssispace-shares" class="ssispace-cards">
			<div class="ssispace-skel" aria-hidden="true"></div>
		</div>
		<p id="ssispace-shares-empty" class="ssispace-empty" hidden><?php p($l->t('Nothing shared with you yet.')); ?></p>
	</section>

	<section class="ssispace-section">
		<h3><?php p($l->t('Quick access')); ?></h3>
		<div class="ssispace-cards">
			<a class="ssispace-card" href="<?php p($_['urlRecent']); ?>">
				<span class="ssispace-card-icon" aria-hidden="true">
					<svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><path d="M13 3a9 9 0 0 0-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42A8.954 8.954 0 0 0 13 21a9 9 0 0 0 0-18zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/></svg>
				</span>
				<span class="ssispace-card-body">
					<span class="ssispace-card-name"><?php p($l->t('Recent')); ?></span>
				</span>
			</a>
			<a class="ssispace-card" href="<?php p($_['urlFavorites']); ?>">
				<span class="ssispace-card-icon" aria-hidden="true">
					<svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><path d="M12 17.27 18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
				</span>
				<span class="ssispace-card-body">
					<span class="ssispace-card-name"><?php p($l->t('Favorites')); ?></span>
				</span>
			</a>
		</div>
	</section>
</div>
</div>
</div>
