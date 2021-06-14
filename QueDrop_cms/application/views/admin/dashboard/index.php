<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4></i> <span class="text-semibold"><?php _el('dashboard'); ?></span></h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?> </a>
			</li>
		</ul>
	</div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
	<div class="row">
		<!-- Today's revenue -->
		<a href="<?php echo base_url()."admin/users";?>">
			<div class="col-lg-3 dashboard-content">
				<div class="panel bg-info-400">
					<div class="panel-body">
						<h3 class="no-margin"><i class="icon-users4 dashboard-icon"></i> <br>Users <br><?php  if(!empty($users)){echo count($users);} else {echo '0';}?></h3>
					</div>
					<div id="today-revenue"></div>
				</div>
			</div>
		</a>
		<!-- /today's revenue -->

		<!-- Today's revenue -->
		<a href="<?php echo base_url()."admin/drivers";?>">
			<div class="col-lg-3 dashboard-content">
				<div class="panel bg-pink-400">
					<div class="panel-body">
						<h3 class="no-margin"><i class="icon-truck dashboard-icon"></i><br>Drivers <br><?php if(!empty($drivers)){echo count($drivers);}else {echo '0';}?></h3>
					</div>
					<div id="today-revenue"></div>
				</div>
			</div>
		</a>
		<!-- /today's revenue -->

		<!-- Today's revenue -->
		<!-- <a href="<?php echo base_url()."/admin/suppliers";?>">
			<div class="col-lg-3 dashboard-content">
				<div class="panel bg-violet-400">
					<div class="panel-body">
						<h3 class="no-margin"><i class="icon-user dashboard-icon"></i> <br>Suppliers <br><?php if(!empty($suppliers)){echo count($suppliers);}?></h3>
					</div>
					<div id="today-revenue"></div>
				</div>
			</div>
		</a> -->
		<!-- /today's revenue -->

		<!-- Today's revenue -->
		<a href="<?php echo base_url()."admin/stores";?>">
			<div class="col-lg-3 dashboard-content">
				<div class="panel bg-teal-400">
					<div class="panel-body">
						<h3 class="no-margin"><i class="icon-store dashboard-icon"></i> <br>Stores <br><?php if(!empty($stores)){echo count($stores);}else {echo '0';}?></h3>
					</div>
					<div id="today-revenue"></div>
				</div>
			</div>
		</a>
		<!-- /today's revenue -->

		<!-- Today's revenue -->
		<!-- <a href="<?php echo base_url()."admin/coupons";?>">
			<div class="col-lg-3 dashboard-content">
				<div class="panel bg-green-400">
					<div class="panel-body">
						<h3 class="no-margin"><i class=" icon-price-tags dashboard-icon"></i> <br>Coupons <br><?php if(!empty($coupons)){echo count($coupons);}?></h3>
					</div>
					<div id="today-revenue"></div>
				</div>
			</div>
		</a> -->
		<!-- /today's revenue -->

		<!-- Today's revenue -->
		<a href="<?php echo base_url()."admin/orders";?>">
			<div class="col-lg-3 dashboard-content">
				<div class="panel bg-orange-400">
					<div class="panel-body">
						<h3 class="no-margin"><i class="icon-cart5 dashboard-icon"></i> <br>Orders <br><?php if(!empty($orders)){echo count($orders);}else {echo '0';}?></h3>
					</div>
					<div id="today-revenue"></div>
				</div>
			</div>
		</a>
		<!-- /today's revenue -->

		<!-- Today's revenue -->
		<a href="<?php echo base_url()."admin/products";?>">
			<div class="col-lg-3 dashboard-content">
				<div class="panel bg-brown-400">
					<div class="panel-body">
					<h3 class="no-margin"><i class="icon-gift dashboard-icon"></i> <br>Products<br><?php if(!empty($products)){echo count($products);}else {echo '0';}?></h3>
					</div>
					<div id="today-revenue"></div>
				</div>
			</div>
		</a>
		<!-- /today's revenue -->

		<!-- Today's revenue -->
		<a href="<?php echo base_url()."admin/offers";?>">
			<div class="col-lg-3 dashboard-content">
				<div class="panel bg-grey-400">
					<div class="panel-body">
						<h3 class="no-margin"><i class="icon-menu6 dashboard-icon"></i> <br>Offers<br><?php if(!empty($offers)){echo count($offers);}else {echo '0';}?></h3>
					</div>
					<div id="today-revenue"></div>
				</div>
			</div>
		</a>
		<!-- /today's revenue -->

		<!-- Today's revenue -->
		<a href="<?php echo base_url()."admin/categories";?>">
			<div class="col-lg-3 dashboard-content">
				<div class="panel bg-blue-400">
					<div class="panel-body">
						<h3 class="no-margin"><i class=" icon-list2 dashboard-icon"></i> <br>Categories<br><?php if(!empty($categories)){echo count($categories);}else {echo '0';}?></h3>
					</div>
					<div id="today-revenue"></div>
				</div>
			</div>
		</a>
		<!-- /today's revenue -->
	</div>
</div>
<!-- /Content area -->