<?php

declare(strict_types=1);

namespace OCA\SSISpace\AppInfo;

use OCA\SSISpace\Listener\HeaderEntryListener;
use OCP\AppFramework\App;
use OCP\AppFramework\Bootstrap\IBootContext;
use OCP\AppFramework\Bootstrap\IBootstrap;
use OCP\AppFramework\Bootstrap\IRegistrationContext;
use OCP\AppFramework\Http\Events\BeforeTemplateRenderedEvent;

class Application extends App implements IBootstrap {
	public const APP_ID = 'ssispace';

	public function __construct(array $urlParams = []) {
		parent::__construct(self::APP_ID, $urlParams);
	}

	#[\Override]
	public function register(IRegistrationContext $context): void {
		// header "Spaces" entry on every logged-in page (app menu is hidden by theming CSS)
		$context->registerEventListener(BeforeTemplateRenderedEvent::class, HeaderEntryListener::class);
	}

	#[\Override]
	public function boot(IBootContext $context): void {
	}
}
