<script type="text/javascript">
$(document).ready(function(){
	$(document).trigger('refresh');
});
</script>
<table class="main-table">
	<thead>
		<tr>
			<?php if ($has_additional_logs): ?>
				<th>Дата</th>
				<th>Сообщение</th>
				<th style="text-align: right;">Поле</th>
				<th style="width: 50%; text-align: right;">Было</th>
				<th style="width: 50%;">Стало</th>
				<th>Login</th>
				<th>IP</th>
			<?php else: ?>
				<th>Дата</th>
				<th style="width: 100%;" colspan="4">Сообщение</th>
				<th>Login</th>
				<th>IP</th>
			<?php endif; ?>
	    </tr>
	</thead>
	<tbody>
		<?php 
			foreach ($logs as $r) { 
				if (empty($r['additional'])): ?>
				<tr class="zebra">
					<td style="white-space: nowrap;"><?php echo date('d.m.Y H:i:s', $r['posted'])?></td>
					<td colspan="4"><?php echo htmlspecialchars($r['kind_desc'])?></td>
					<td><?php echo htmlspecialchars($r['poster_username'])?></td>
					<td><?php echo $r['ip']?></td>
				</tr>
			<?php else: 
				$is_first_additional = true;
				foreach ($r['additional'] as $a) { ?>
					<tr class="zebra">
						<td style="white-space: nowrap;"><?php echo $is_first_additional ? date('d.m.Y H:i:s', $r['posted']) : '&nbsp;'?></td>
						<td><?php echo $is_first_additional ? htmlspecialchars($r['kind_desc']) : '&nbsp;'?></td>
						<td class="d"><?php echo htmlspecialchars($a['desc'])?></td>
						<td class="v" style="text-align: right;"><?php echo $a['old'] ? htmlspecialchars($a['old']) : '-'?></td>
						<td class="v"><?php echo $a['new'] ? htmlspecialchars($a['new']) : '-'?></td>
						<td><?php echo $is_first_additional ? htmlspecialchars($r['poster_username']) : '&nbsp;'?></td>
						<td><?php echo $is_first_additional ? $r['ip'] : '&nbsp;'?></td>
					</tr>
			<?php
					$is_first_additional = false;
				} //foreach ?>
			<?php endif; ?>
		<?php } //foreach ?>		
	</tbody>
</table>