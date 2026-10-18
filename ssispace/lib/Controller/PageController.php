<?php

declare(strict_types=1);

namespace OCA\SSISpace\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http\Attribute\NoAdminRequired;
use OCP\AppFramework\Http\Attribute\NoCSRFRequired;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\IURLGenerator;
use OCP\Util;

class PageController extends Controller {

	public function __construct(
		string $appName,
		\OCP\IRequest $request,
		private IURLGenerator $urlGenerator,
	) {
		parent::__construct($appName, $request);
	}

	#[NoAdminRequired]
	#[NoCSRFRequired]
	public function index(): TemplateResponse {
		Util::addScript('ssispace', 'ssispace-main');
		Util::addStyle('ssispace', 'ssispace');
		return new TemplateResponse('ssispace', 'main', [
			'urlMySpace' => $this->urlGenerator->linkToRoute('files.view.indexView', ['view' => 'files']),
			'urlRecent' => $this->urlGenerator->linkToRoute('files.view.indexView', ['view' => 'recent']),
			'urlFavorites' => $this->urlGenerator->linkToRoute('files.view.indexView', ['view' => 'favorites']),
			'urlFilesBase' => $this->urlGenerator->linkToRoute('files.view.indexView', ['view' => 'files']),
		], 'user');
	}
}
