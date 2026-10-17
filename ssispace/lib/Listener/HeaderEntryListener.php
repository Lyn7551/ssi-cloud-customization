<?php

declare(strict_types=1);

namespace OCA\SSISpace\Listener;

use OCP\AppFramework\Http\Events\BeforeTemplateRenderedEvent;
use OCP\EventDispatcher\Event;
use OCP\EventDispatcher\IEventListener;
use OCP\Util;

/**
 * Injects the "Spaces" header entry script on every logged-in page render.
 *
 * @template-implements IEventListener<BeforeTemplateRenderedEvent>
 */
class HeaderEntryListener implements IEventListener {

	#[\Override]
	public function handle(Event $event): void {
		if (!($event instanceof BeforeTemplateRenderedEvent)) {
			return;
		}
		if (!$event->isLoggedIn()) {
			return;
		}
		Util::addScript('ssispace', 'ssispace-header');
	}
}
