<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold">View Service Category</span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/servicecategory'); ?>"><?php _el('service_category'); ?></a>
			</li>
			<li class="active"><?php _el('view'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">	
	<form id="drivr" action="" method="POST">
		<div class="row">
			<div class="col-md-12 ">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-12">
								<h5 class="panel-title">
									<strong>Service Category Details</strong>
								</h5>
							</div>
						</div>
					</div>
					
					<!-- /Panel heading -->
					<!-- Panel body -->
					<?php //echo "<pre>"; print_r($driver);?>
					<div class="panel-body">
							<div class="row">
						<div class="col-lg-3 col-sm-6">
							<?php if(!empty($category['service_category_image'])) {?>
							<div class="thumbnail">
								<div class="thumb">
									<img src="<?php echo VIEW_SERVICE_CATEGORIES.$category['service_category_image'];?>" alt="" style="height: 240px;" onError="this.onerror=null;this.src='<?=base_url() . 'assets/admin/images/no_image.png'?>';">
									<div class="caption-overflow">
										<span>
											<a href="<?php echo VIEW_SERVICE_CATEGORIES.$category['service_category_image'];?>" data-popup="lightbox" class="btn border-white text-white btn-flat btn-icon btn-rounded"><i class="icon-plus3"></i></a>
											<!-- <a href="#" class="btn border-white text-white btn-flat btn-icon btn-rounded ml-5"><i class="icon-link2"></i></a> -->
										</span>
									</div>
								<div class="caption">
									<h6 class="no-margin">
										<a href="#" class="text-default">Service Category Image Photo</a> 
										<a href="#" class="text-muted"><i class="icon-three-bars pull-right"></i></a>
									</h6>
								</div>
							</div>
							</div> <?php } else { echo "Driver Photo Not Available"; } ?>
						</div>
                        <div class="col-lg-9 col-sm-6">
                            <?php if(!empty($category)) {	?>
                                <div class="col-md-12">
                                    <div>
                                        <span><b>Name:</b> <?php echo $category['service_category_name'];?></span><br>
                                        <span><b>Description:</b> <?php echo $category['service_category_description'];?></span><br>
                                    </div>
                                </div>
                                    
                            <?php }?>   
                        </div>
                    </div>
					</div>
					<!-- /Panel body -->
				</div>
				<!-- /Panel -->
			</div>
			
			
				
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
			<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
	</form>
</div>
<!-- /Content area -->




