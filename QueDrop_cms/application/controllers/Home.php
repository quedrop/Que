<?php
defined('BASEPATH') OR exit('No direct script access allowed');
class Home extends Frontend_Controller
{
	public function __construct()
	{
		parent::__construct();
	}

	public function index()
	{
		$this->set_page_title('Home');

		$data = [
			'heading' => 'Hello, world!',
			'text'    => 'This is a template for a simple marketing or informational website. It includes a large callout called a jumbotron and three supporting pieces of content. Use it as a starting point to create something more unique.',
			'items'   => [
				[
					'name'        => 'Item-1',
					'description' => 'Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo'
				],
				[
					'name'        => 'Item-2',
					'description' => 'Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.'
				],
				[
					'name'        => 'Item-3',
					'description' => 'Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui'
				]
			]
		];

		$this->template->load('index', 'content', 'home', $data);
	}

}
