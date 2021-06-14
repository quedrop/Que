<!-- Content area -->
<div class="content">
    <!-- Panel -->
    <div class="panel panel-flat">
        <!-- Panel heading -->
      <div class="panel-heading">
        <b>Driver Orders</b> 
     </div>
    <!-- /Panel heading -->
        
        
        
        
        <!-- Listing table -->
        <div class="panel-body table-responsive">
            <table id="users_table" class="table table-bordered table-striped">
                <thead>
                    <tr>
                       
                        <th width="2%">
                           Sn.
                        </th>
                        
                        <th width="2%"><?php _el('name'); ?></th>
                        
                        <th width="2%" class="text-center"><?php _el('actions'); ?></th>
                       
                    </tr>
                </thead>
                <tbody>
                    <?php //echo "<pre>"; print_r($drivers);
                    if(!empty($drivers)){
                    $i = 0; 
                    foreach ($drivers as $key => $user) { $i++;?>
                    <tr>
                        <?php 
                            $disabled = '';
                             
                        ?>
                        <td>
                            <?php echo $i;?>
                        </td>
                        <td>
                            <?php echo ucfirst($user[0]['first_name']).'&nbsp;'.ucfirst($user[0]['last_name']); ?>
                        </td>
                        
                        <td class="text-center">
                          <a data-popup="tooltip" data-placement="top"  title="<?php _el('view') ?>" href="<?php echo site_url('admin/payments/view_driver/').$user[0]['user_id'].'?start_date='.$start_date.'&end_date='.$end_date; ?>" id="<?php echo $user[0]['user_id']; ?>" class="text-info"><i class="icon-eye"></i></a>
                        </td>
                    </tr>
                    <?php } 
                    } else {
                      ?>
                      <tr>
                        <td>No record found</td>
                        <td></td>
                        <td></td>
                      </tr>
                      <?php 
                    } ?>
                </tbody>
            </table>           
        </div>
        <!-- /Listing table -->
    </div>
    <!-- /Panel -->
</div>
<!-- /Content area -->

<!-- Content area -->
<div class="content">
  <!-- Panel -->
  <div class="panel panel-flat">
    
      <!-- Panel heading -->
      <div class="panel-heading">
         <b>Store Orders</b> 
      </div>
      <!-- /Panel heading -->
    
    
    <!-- Listing table -->
    <div class="panel-body table-responsive">
      <table id="orders_table" class="table table-bordered table-striped">
        <thead>
          <tr>
            
            <th>
              Sn.
            </th>
            
            <th>Store Name</th>
            <th class="text-center"><?php _el('actions'); ?></th>
            
          </tr>
        </thead>
        <tbody>
          <?php 
          if(!empty($store)){
          $i = 0;
          foreach ($store as $key => $order) { $i++;
            if(!empty($order)){
             ?>
          <tr>
            <td>
              <?php echo $i;?>
            </td>
           
            <td><?php echo ucfirst($order[0]['store_name']);?></td>
            <td class="text-center">
                <a data-popup="tooltip" data-placement="top"  title="<?php _el('view') ?>" href="<?php echo site_url('admin/payments/view_store/').$order[0]['store_id'].'?start_date='.$start_date.'&end_date='.$end_date; ?>" id="<?php echo $order[0]['store_id']; ?>" class="text-info">
                  <i class="icon-eye"></i>
                </a>
            </td>
            
          </tr>
          <?php } 
        
        } } else {
          ?>
          <tr>
            <td>No record found</td>
            <td></td>
            <td></td>
          </tr>
          <?php 
        } ?>
        </tbody>
      </table>      
    </div>
    <!-- /Listing table -->
  </div>
  <!-- /Panel -->
</div>
<!-- /Content area -->


<script type="text/javascript">
$(function() {

    $('#users_table').DataTable({
        buttons: {
            dom: {
            button: {
                className: 'btn btn-default'
            }
            },
            buttons: [
            'copyHtml5',                
            'csvHtml5',
            'pdfHtml5'
            ]
        },
        'columnDefs': [ {
        'targets': [0], /* column index */
        'orderable': false, /* disable sorting */
        }],
         
    });

    //add class to style style datatable select box
    $('div.dataTables_length select').addClass('datatable-select');
 });



</script>
