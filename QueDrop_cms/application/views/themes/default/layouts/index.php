<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title><?php echo $this->page_title; ?></title>
    <link rel="stylesheet" href="<?php echo base_url('assets/themes/default/css/bootstrap.min.css'); ?>" >
    <link rel="stylesheet" href="<?php echo base_url('assets/themes/default/css/style.css'); ?>" >
    <script type="text/javascript" src="<?php echo base_url('assets/admin/js/core/libraries/jquery.min.js'); ?>"></script>
    <script type="text/javascript" src="<?php echo base_url('assets/admin/js/plugins/forms/validation/validate.min.js'); ?>"></script>
</head>

<body>
	<nav class="navbar navbar-inverse navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="<?php echo site_url(); ?>"><?php echo get_settings('company_name'); ?></a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
            <ul class="nav navbar-nav navbar-right"> 
            <?php if (is_user_logged_in()) { ?>  
                <li><a href="#">Welcome <?php echo get_loggedin_info('username'); ?></a></li>
                <li><a href="<?php echo site_url('authentication/logout'); ?>"><?php _el('logout'); ?></a></li>
            <?php } else { ?>           
                <li><a href="<?php echo site_url('authentication/index') ?>">Login</a></li>
                <li><a href="<?php echo site_url('authentication/signup') ?>">Sign Up</a></li>
            <?php } ?>    
            </ul>
        </div><!--/.navbar-collapse -->
      </div>
    </nav>
	<?php echo $content; ?>
	  <hr>
      <footer>
        <p>&copy; <?php echo date('Y') ?> <?php echo get_settings('company_name'); ?></a></p>
      </footer>
    </div>
</body>
</html>